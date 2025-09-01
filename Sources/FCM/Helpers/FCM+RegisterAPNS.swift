import AsyncHTTPClient

public struct APNSToFirebaseToken {
    public let registration_token, apns_token: String
    public let isRegistered: Bool
}

extension FCM {
    /// Helper method which registers your pure APNS token in Firebase Cloud Messaging
    /// and returns firebase tokens for each APNS token
    public func registerAPNS(
        appBundleId: String,
        sandbox: Bool = false,
        tokens: String...
    ) async throws -> [APNSToFirebaseToken] {
        try await registerAPNS(appBundleId: appBundleId, sandbox: sandbox, tokens: tokens)
    }

    /// Helper method which registers your pure APNS token in Firebase Cloud Messaging
    /// and returns firebase tokens for each APNS token
    public func registerAPNS(
        appBundleId: String,
        sandbox: Bool = false,
        tokens: [String]
    ) async throws -> [APNSToFirebaseToken] {
        guard tokens.count <= 100 else {
            throw RegisterAPNSError.tooManyTokens
        }
        
        guard tokens.count > 0 else {
            return []
        }

        let url = Self.iidURL + "batchImport"

        struct Payload: Encodable {
            let application: String
            let sandbox: Bool
            let apns_tokens: [String]
        }
        let payload = Payload(application: appBundleId, sandbox: sandbox, apns_tokens: tokens)

        struct Result: Codable {
            struct Result: Codable {
                let registration_token, apns_token, status: String
            }
            let results: [Result]
        }
        let result: Result = try await executeHTTPRequest(url: url, with: payload)

        return result.results.map {
            .init(registration_token: $0.registration_token, apns_token: $0.apns_token, isRegistered: $0.status == "OK")
        }
    }
}

enum RegisterAPNSError: Error {
    case tooManyTokens
}
