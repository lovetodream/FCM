import AsyncHTTPClient
import NIOCore

extension FCM {
    func getAccessToken() async throws -> String {
        if !gAuth.hasExpired, let token = accessToken {
            return token
        }
        
        let jwt = try await self.getJWT()

        let response = try await executeHTTPRequest(
            url: Self.audience,
            with: [
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": jwt,
            ],
            headers: ["Content-Type": "application/json"]
        )

        struct Result: Codable {
            let access_token: String
        }

        var responseBody = try await response.body.collect(upTo: 2 * 1024 * 1024)
        let result = try responseBody.readJSONDecodable(Result.self, length: responseBody.readableBytes)
        guard let result else {
            throw AccessTokenError.missingToken
        }
        self.accessToken = result.access_token
        return result.access_token
    }
}

enum AccessTokenError: Error {
    case missingToken
}
