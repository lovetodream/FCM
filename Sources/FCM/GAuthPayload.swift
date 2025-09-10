import JWTKit

struct GAuthPayload: JWTPayload {
    let uid: String
    
    var exp: ExpirationClaim
    var iat: IssuedAtClaim
    var iss: IssuerClaim
    var sub: SubjectClaim
    var scope: String
    var aud: AudienceClaim
    
    init(iss: IssuerClaim, sub: SubjectClaim, scope: String, aud: AudienceClaim, iat: FCMDate = .now) {
        self.uid = FCMUUID().uuidString
        self.exp = ExpirationClaim(value: iat.addingTimeInterval(3600))
        self.iat = IssuedAtClaim(value: iat)
        self.iss = iss
        self.sub = sub
        self.scope = scope
        self.aud = aud
    }

    func verify(using algorithm: some JWTAlgorithm) throws {
        // not used
    }

    var hasExpired: Bool {
        do {
            try exp.verifyNotExpired()
            return false
        } catch {
            return true
        }
    }

    func updated(iat: FCMDate = .now) -> Self {
        GAuthPayload(iss: iss, sub: sub, scope: scope, aud: aud, iat: iat)
    }
}
