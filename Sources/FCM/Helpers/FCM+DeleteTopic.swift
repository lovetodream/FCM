import AsyncHTTPClient
import NIOCore

extension FCM {
    public func deleteTopic(_ name: String, tokens: String...) async throws {
        try await deleteTopic(name, tokens: tokens)
    }

    public func deleteTopic(_ name: String, tokens: [String]) async throws {
        try await _deleteTopic(name, tokens: tokens)
    }

    private func _deleteTopic(_ name: String, tokens: [String]) async throws {
        let url = Self.iidURL + "batchRemove"

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
    }
}
