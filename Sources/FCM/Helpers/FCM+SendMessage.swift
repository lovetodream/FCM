extension FCM {
    public func send(_ message: FCMMessageDefault) async throws -> String {
        try await _send(message)
    }
    
    private func _send(_ message: FCMMessageDefault) async throws -> String {
        var message = message
        
        if message.apns == nil, let apnsDefaultConfig = configuration.apnsDefaultConfig {
            message.apns = apnsDefaultConfig
        }
        if message.android == nil, let androidDefaultConfig = configuration.androidDefaultConfig {
            message.android = androidDefaultConfig
        }
        if message.webpush == nil, let webpushDefaultConfig = configuration.webpushDefaultConfig {
            message.webpush = webpushDefaultConfig
        }

        let url = Self.actionsBaseURL + configuration.projectId + "/messages:send"
        let accessToken = try await getAccessToken()
        struct Payload: Encodable {
            let message: FCMMessageDefault
        }
        let payload = Payload(message: message)

        struct Result: Decodable {
            let name: String
        }
        let result: Result = try await executeHTTPRequest(url: url, with: payload, headers: ["Content-Type": "application/json", "Authorization": "Bearer \(accessToken)"])

        return result.name
    }
}
