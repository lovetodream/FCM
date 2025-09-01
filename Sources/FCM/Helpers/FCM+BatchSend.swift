import AsyncHTTPClient
import MultipartKit
import NIOCore
import NIOHTTP1

extension FCM {

    private func _send(_ message: FCMMessageDefault, tokens: [String]) async throws -> [String] {

        let urlPath = "/v1/projects/" + configuration.projectId + "/messages:send"

        let accessToken = try await getAccessToken()
        
        var result = [String]()
        for chunk in tokens.chunked(into: 500) {
            let partial = try await self._sendChunk(
                message,
                tokens: chunk,
                urlPath: urlPath,
                accessToken: accessToken
            )
            result.append(contentsOf: partial)
        }
        
        return result
    }

    private func _sendChunk(
        _ message: FCMMessageDefault,
        tokens: [String],
        urlPath: String,
        accessToken: String
    ) async throws -> [String] {
        let boundary = "subrequest_boundary"

        struct Payload: Encodable {
            let message: FCMMessageDefault
        }

        let parts: [MultipartPart] = try tokens.map { token in
            var partBody = ByteBufferAllocator().buffer(capacity: 0)

            partBody.writeString("""
                POST \(urlPath)\r
                Content-Type: application/json\r
                accept: application/json\r
                \r

                """)

            let message = FCMMessageDefault(
                token: token,
                notification: message.notification,
                data: message.data,
                name: message.name,
                android: message.android ?? configuration.androidDefaultConfig,
                webpush: message.webpush ?? configuration.webpushDefaultConfig,
                apns: message.apns ?? configuration.apnsDefaultConfig
            )

            try partBody.writeJSONEncodable(Payload(message: message))

            return MultipartPart(headerFields: [.contentType: "application/http"], body: partBody.readableBytesView)
        }

        let body: ByteBufferView = MultipartSerializer(boundary: boundary).serialize(parts: parts)

        var request = HTTPClientRequest(url: Self.batchURL)
        request.headers = [
            "Content-Type": "multipart/mixed; boundary=\(boundary)",
            "Authorization": "Bearer \(accessToken)"
        ]
        request.body = .bytes(body)

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))
        try await response.validate()

        guard
            let boundary = response.headers.getParameter("Content-Type", "boundary")
        else {
            throw BatchResponseError.missingBoundary
        }

        let responseBody = try await response.body.collect(upTo: 2 * 1024 * 1024)
        struct Result: Decodable {
            let name: String
        }

        let parser: MultipartParser<ByteBufferView> = MultipartParser(boundary: boundary)
        let result = try parser.parse(responseBody.readableBytesView).compactMap { part in
            var body = ByteBuffer(part.body)
            let bytes = body.readableBytesView
            if let indexOfBodyStart = bytes.firstIndex(of: 0x7B) /* '{' */ {
                body.moveReaderIndex(to: indexOfBodyStart)
                if let name = try? body.readJSONDecodable(Result.self, length: body.readableBytes)?.name {
                    return name
                }
            }
            return nil
        }

        return result
    }
}

enum BatchResponseError: Error {
    case missingBoundary
}

private extension Collection where Index == Int {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
