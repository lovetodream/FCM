import AsyncHTTPClient


extension FCM {
    public func getTopics(token: String) async throws -> [String] {
        let url = Self.iidURL + "info/\(token)?details=true"

        struct Result: Codable {
            let rel: Relations

            struct Relations: Codable {
                let topics: [String: TopicMetadata]
            }

            struct TopicMetadata: Codable {
                let addDate: String
            }
        }
        let result: Result = try await executeHTTPRequest(url: url)
        return Array(result.rel.topics.keys)
    }
}
