import AsyncHTTPClient
import NIOCore
import NIOHTTP1

extension FCMClient {
    @discardableResult
    func executeHTTPRequest(
        url: String,
        with jsonPayload: some Encodable,
        headers: HTTPHeaders? = nil
    ) async throws -> HTTPClientResponse {
        let _ = try await getAccessToken()

        var request = HTTPClientRequest(url: url)
        request.headers = headers ?? [
            "Authorization": "key=\(configuration.serverKey)",
            "Content-Type": "application/json"
        ]
        request.method = .POST
        var buffer = ByteBuffer()
        try buffer.writeJSONEncodable(jsonPayload)
        request.body = .bytes(buffer)

        let response = try await httpClient.execute(request, timeout: .seconds(30))
        try await response.validate()

        return response
    }

    func executeHTTPRequest<T: Decodable>(
        url: String,
        with jsonPayload: some Encodable,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        let response = try await executeHTTPRequest(url: url, with: jsonPayload, headers: headers)

        var body = try await response.body.collect(upTo: 2 * 1024 * 1024)
        return try body.readJSONDecodable(T.self, length: body.readableBytes).unsafelyUnwrapped
    }

    func executeHTTPRequest<T: Decodable>(
        url: String,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        let _ = try await getAccessToken()

        var request = HTTPClientRequest(url: url)
        request.headers = headers ?? ["Authorization": "key=\(configuration.serverKey)"]
        request.method = .GET

        let response = try await httpClient.execute(request, timeout: .seconds(30))
        try await response.validate()

        var body = try await response.body.collect(upTo: 2 * 1024 * 1024)
        return try body.readJSONDecodable(T.self, length: body.readableBytes).unsafelyUnwrapped
    }
}
