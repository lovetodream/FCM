import NIOCore
import NIOFileSystem

public struct FCMConfiguration: Sendable {
    let email: String
    let projectId: String
    let key: String

    // MARK: Default configurations
    
    public var apnsDefaultConfig: FCMApnsConfig<FCMApnsPayload>?
    public var androidDefaultConfig: FCMAndroidConfig?
    public var webpushDefaultConfig: FCMWebpushConfig?

    // MARK: Initializers
    
    public init (email: String, projectId: String, key: String) {
        self.email = email
        self.projectId = projectId
        self.key = key
    }
    
    public init(email: String, projectId: String, keyPath: String) async throws {
        self.email = email
        self.projectId = projectId
        self.key = try await Self.readKey(from: keyPath)
    }
    
    public init(pathToServiceAccountKey path: String) async throws {
        let s = try await Self.readServiceAccount(at: path)
        self.email = s.client_email
        self.projectId = s.project_id
        self.key = s.private_key
    }

    // MARK: Helpers
    
    private static func readKey(from path: String) async throws -> String {
        try await FileSystem.shared.withFileHandle(forReadingAt: .init(path)) { read in
            var key = ""
            for try await var chunk in read.readChunks() {
                key += chunk.readString(length: chunk.readableBytes).unsafelyUnwrapped
            }
            return key
        }
    }
    
    private struct ServiceAccount: Codable {
        let project_id, private_key, client_email: String
    }
    
    private static func readServiceAccount(at path: String) async throws -> ServiceAccount {
        try await FileSystem.shared.withFileHandle(forReadingAt: .init(path)) { read in
            let size = try await read.info().size
            var buffer = ByteBufferAllocator().buffer(capacity: numericCast(size))
            for try await var chunk in read.readChunks() {
                buffer.writeBuffer(&chunk)
            }
            return try buffer.readJSONDecodable(ServiceAccount.self, length: buffer.readableBytes).unsafelyUnwrapped
        }
    }
}
