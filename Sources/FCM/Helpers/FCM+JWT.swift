import JWTKit

extension FCMClient {
    func generateJWT() async throws -> String {
        self.gAuth.withLock { $0 = $0.updated() }
        return try await self.keys.sign(gAuth.withLock { $0 })
    }
    
    func getJWT() async throws -> String {
        if !gAuth.withLock({ $0.hasExpired }) {
            return jwt.withLock { $0 }
        }
        let jwt = try await generateJWT()
        self.jwt.withLock { $0 = jwt }
        return jwt
    }
}
