import JWTKit

struct GAuthPayload: JWTPayload {
    let uid: String
    
    var exp: ExpirationClaim
    var iat: IssuedAtClaim
    var iss: IssuerClaim
    var sub: SubjectClaim
    var scope: String
    var aud: AudienceClaim
    
    static var expirationClaim: ExpirationClaim {
        return ExpirationClaim(value: FCMDate.now.addingTimeInterval(3600))
    }

    init(iss: String, sub: String, scope: String, aud: String) {
        self.uid = FCMUUID().uuidString
        self.exp = GAuthPayload.expirationClaim
        self.iat = IssuedAtClaim(value: .now)
        self.iss = IssuerClaim(value: iss)
        self.sub = SubjectClaim(value: sub)
        self.scope = scope
        self.aud = AudienceClaim(value: aud)
    }
    
    private init(iss: IssuerClaim, sub: SubjectClaim, scope: String, aud: AudienceClaim) {
        self.uid = FCMUUID().uuidString
        self.exp = GAuthPayload.expirationClaim
        self.iat = IssuedAtClaim(value: .now)
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

    func updated() -> Self {
        GAuthPayload(iss: iss, sub: sub, scope: scope, aud: aud)
    }
}
