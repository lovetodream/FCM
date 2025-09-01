import AsyncHTTPClient

extension HTTPClientResponse {
    func validate() async throws {
        guard 200 ..< 300 ~= self.status.code else {
            var body = try await self.body.collect(upTo: 2 * 1024 * 1024)
            if let error = try? body.readJSONDecodable(GoogleError.self, length: body.readableBytes) {
                throw error
            }
            body.moveReaderIndex(to: 0)
            let rawError = body.readString(length: body.readableBytes).unsafelyUnwrapped
            throw GoogleError.Raw(message: rawError)
        }
    }
}
