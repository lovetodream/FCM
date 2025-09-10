import JWTKit

extension FCMClient {
    func generateJWT() async throws -> String {
        self.gAuth.withLock { $0 = $0.updated() }
        let jwt = try await self.keys.sign(gAuth.withLock { $0 })
        return jwt
    }
}
