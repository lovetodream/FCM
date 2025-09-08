import AsyncHTTPClient
import NIOCore
import Synchronization
import JWTKit

// MARK: Engine

public final class FCMClient: Sendable {

    let httpClient: HTTPClient

    static let scope = "https://www.googleapis.com/auth/cloud-platform"
    static let audience = "https://www.googleapis.com/oauth2/v4/token"
    static let actionsBaseURL = "https://fcm.googleapis.com/v1/projects/"

    // MARK: Default configurations

    public let configuration: FCMConfiguration

    let gAuth: Mutex<GAuthPayload>
    let jwt: Mutex<String>
    let accessToken: Mutex<String?> = Mutex(nil)

    let keys: JWTKeyCollection

    public init(httpClient: HTTPClient, configuration: FCMConfiguration) async throws {
        self.httpClient = httpClient
        self.configuration = configuration
        self.gAuth = Mutex(GAuthPayload(iss: configuration.email, sub: configuration.email, scope: Self.scope, aud: Self.audience))
        guard let pemData = configuration.key.data(using: .utf8) else {
            fatalError("FCM unable to prepare PEM data for JWT")
        }
        let pk = try Insecure.RSA.PrivateKey(pem: pemData)
        self.keys = await JWTKeyCollection().add(rsa: pk, digestAlgorithm: .sha256)
        self.jwt = Mutex("")
        _ = try await generateJWT()
    }
}

