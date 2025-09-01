import AsyncHTTPClient
import NIOCore

extension FCMClient {
    public func createTopic(_ name: String? = nil, tokens: [String]) async throws -> String {
        try await _createTopic(name, tokens: tokens)
    }

    private func _createTopic(_ name: String? = nil, tokens: [String]) async throws -> String {
        let url = Self.iidURL + "batchAdd"
        let name = name ?? FCMUUID().uuidString

        struct Payload: Encodable {
            let to: String
            let registration_tokens: [String]

            init(to: String, registration_tokens: [String]) {
                self.to = "/topics/\(to)"
                self.registration_tokens = registration_tokens
            }
        }
        let payload = Payload(to: name, registration_tokens: tokens)
        try await executeHTTPRequest(url: url, with: payload)

        return name
    }
}
