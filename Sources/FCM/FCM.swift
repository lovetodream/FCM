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
    let accessToken: Mutex<String?> = Mutex(nil)

    let keys: JWTKeyCollection

    public convenience init(httpClient: HTTPClient, configuration: FCMConfiguration) async throws {
        try await self.init(_httpClient: httpClient, _configuration: configuration)

    }

    init(_httpClient httpClient: HTTPClient, _configuration configuration: FCMConfiguration) async throws {
        self.httpClient = httpClient
        self.configuration = configuration
        self.gAuth = Mutex(GAuthPayload(
            iss: .init(value: configuration.email),
            sub: .init(value: configuration.email),
            scope: Self.scope,
            aud: .init(value: Self.audience),
            iat: .distantPast
        ))
        let pk = try Insecure.RSA.PrivateKey(pem: .init(configuration.key.utf8))
        self.keys = await JWTKeyCollection().add(rsa: pk, digestAlgorithm: .sha256)
    }
}

