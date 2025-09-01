import AsyncHTTPClient
import NIOCore

// MARK: Engine

public final class FCM: @unchecked Sendable { // TODO: REMOVE UNCHECKED

    let httpClient: HTTPClient

    static let scope = "https://www.googleapis.com/auth/cloud-platform"
    static let audience = "https://www.googleapis.com/oauth2/v4/token"
    static let actionsBaseURL = "https://fcm.googleapis.com/v1/projects/"
    static let iidURL = "https://iid.googleapis.com/iid/v1:"
    static let batchURL = "https://fcm.googleapis.com/batch"

    // MARK: Default configurations

    public let configuration: FCMConfiguration

    var gAuth: GAuthPayload // TODO: might be let?
    var jwt: String
    var accessToken: String?

    public init(httpClient: HTTPClient, configuration: FCMConfiguration) async throws {
        self.httpClient = httpClient
        self.configuration = configuration
        self.gAuth = GAuthPayload(iss: configuration.email, sub: configuration.email, scope: Self.scope, aud: Self.audience)
        self.jwt = ""
        self.jwt = try await generateJWT()
    }
}

