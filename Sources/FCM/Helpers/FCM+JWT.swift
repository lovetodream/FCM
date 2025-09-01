import JWTKit

extension FCM {
    func generateJWT() async throws -> String {
        guard let pemData = configuration.key.data(using: .utf8) else {
            fatalError("FCM unable to prepare PEM data for JWT")
        }
        self.gAuth = self.gAuth.updated() // TODO: just changes id, do this some other way?
        let pk = try Insecure.RSA.PrivateKey(pem: pemData)
        let keys = await JWTKeyCollection().add(rsa: pk, digestAlgorithm: .sha256)
        return try await keys.sign(gAuth)
    }
    
    func getJWT() async throws -> String {
        if !gAuth.hasExpired {
            return jwt
        }
        let jwt = try await generateJWT()
        self.jwt = jwt
        return jwt
    }
}
