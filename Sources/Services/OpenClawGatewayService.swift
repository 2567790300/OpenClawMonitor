import Foundation
import Combine

// MARK: - ACP Message Types
struct ACPMessage: Codable {
    let type: String
    let id: String?
    let method: String?
    let params: ACPParams?
    let result: AnyCodable?
    let error: ACPError?
}

struct ACPParams: Codable {
    let token: String?
    let method: String?
    let args: [String: AnyCodable]?
}

struct ACPError: Codable {
    let code: Int
    let message: String
}

// MARK: - Gateway Status Models
struct GatewayStatus: Codable, Identifiable {
    var id: String { "gateway" }
    let version: String
    let runtime: String
    let uptime: Int?
    let rpcStatus: String
    let channels: [String: ChannelStatus]?
    let models: [ModelStatus]?
    let crons: [CronStatus]?
    let skills: [SkillStatus]?
    let agents: [AgentStatus]?
}

struct ChannelStatus: Codable, Identifiable {
    var id: String { name }
    let name: String
    let enabled: Bool
    let status: String
    let account: String?
}

struct ModelStatus: Codable, Identifiable {
    var id: String { modelId }
    let modelId: String
    let provider: String
    let status: String
    let isPrimary: Bool?
}

struct CronStatus: Codable, Identifiable {
    var id: String { cronId }
    let cronId: String
    let schedule: String
    let lastRun: String?
    let nextRun: String?
    let status: String
}

struct SkillStatus: Codable, Identifiable {
    var id: String { skillId }
    let skillId: String
    let name: String
    let enabled: Bool
    let version: String?
}

struct AgentStatus: Codable, Identifiable {
    var id: String { agentId }
    let agentId: String
    let name: String
    let status: String
    let model: String?
    let isActive: Bool
}

// MARK: - Connection State
enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case authenticating
    case connected
    case error(String)

    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .authenticating: return "Authenticating..."
        case .connected: return "Connected"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

// MARK: - OpenClaw Gateway Service
@MainActor
class OpenClawGatewayService: ObservableObject {
    // MARK: - Configuration
    private let gatewayHost: String
    private let gatewayPort: Int
    private let authToken: String

    // MARK: - Published Properties
    @Published var connectionState: ConnectionState = .disconnected
    @Published var gatewayStatus: GatewayStatus?
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var pingTimer: Timer?
    private var messageId: Int = 0

    // MARK: - Initialization
    init(host: String = "127.0.0.1", port: Int = 18790, token: String = "19dac224657ce51af8e3860ae932d649cd00a65856ccec52") {
        self.gatewayHost = host
        self.gatewayPort = port
        self.authToken = token
    }

    // MARK: - Connection Methods
    func connect() async {
        guard connectionState != .connected && connectionState != .connecting else { return }

        connectionState = .connecting
        errorMessage = nil

        let urlString = "ws://\(gatewayHost):\(gatewayPort)"
        guard let url = URL(string: urlString) else {
            connectionState = .error("Invalid URL")
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)

        webSocketTask = session?.webSocketTask(with: url)
        webSocketTask?.resume()

        // Start listening for messages
        await receiveMessages()

        // Send authentication
        await authenticate()
    }

    func disconnect() {
        pingTimer?.invalidate()
        pingTimer = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        session?.invalidateAndCancel()
        session = nil
        connectionState = .disconnected
        gatewayStatus = nil
    }

    // MARK: - Authentication
    private func authenticate() async {
        connectionState = .authenticating

        let authMessage: [String: Any] = [
            "type": "req",
            "id": generateMessageId(),
            "method": "auth",
            "params": [
                "token": authToken
            ]
        ]

        await sendJSON(authMessage)
    }

    // MARK: - Request Methods
    func requestGatewayStatus() async {
        let request: [String: Any] = [
            "type": "req",
            "id": generateMessageId(),
            "method": "gateway.status",
            "params": [:]
        ]
        await sendJSON(request)
    }

    func requestChannelsStatus() async {
        let request: [String: Any] = [
            "type": "req",
            "id": generateMessageId(),
            "method": "channels.list",
            "params": [:]
        ]
        await sendJSON(request)
    }

    func requestModelsStatus() async {
        let request: [String: Any] = [
            "type": "req",
            "id": generateMessageId(),
            "method": "models.list",
            "params": [:]
        ]
        await sendJSON(request)
    }

    func requestCronsStatus() async {
        let request: [String: Any] = [
            "type": "req",
            "id": generateMessageId(),
            "method": "crons.list",
            "params": [:]
        ]
        await sendJSON(request)
    }

    func requestSkillsStatus() async {
        let request: [String: Any] = [
            "type": "req",
            "id": generateMessageId(),
            "method": "skills.list",
            "params": [:]
        ]
        await sendJSON(request)
    }

    func requestAgentsStatus() async {
        let request: [String: Any] = [
            "type": "req",
            "id": generateMessageId(),
            "method": "agents.list",
            "params": [:]
        ]
        await sendJSON(request)
    }

    func refreshAllStatus() async {
        await requestGatewayStatus()
        await requestChannelsStatus()
        await requestModelsStatus()
        await requestCronsStatus()
        await requestSkillsStatus()
        await requestAgentsStatus()
    }

    // MARK: - WebSocket Communication
    private func sendJSON(_ dictionary: [String: Any]) async {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let string = String(data: data, encoding: .utf8) else {
            return
        }

        do {
            try await webSocketTask?.send(.string(string))
        } catch {
            errorMessage = "Send error: \(error.localizedDescription)"
        }
    }

    private func receiveMessages() async {
        guard let webSocketTask = webSocketTask else { return }

        do {
            let message = try await webSocketTask.receive()

            switch message {
            case .string(let text):
                await handleMessage(text)
            case .data(let data):
                if let text = String(data: data, encoding: .utf8) {
                    await handleMessage(text)
                }
            @unknown default:
                break
            }

            // Continue listening
            await receiveMessages()
        } catch {
            connectionState = .error("Connection lost: \(error.localizedDescription)")
        }
    }

    private func handleMessage(_ text: String) async {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return
        }

        switch type {
        case "res":
            await handleResponse(json)
        case "event":
            await handleEvent(json)
        default:
            break
        }
    }

    private func handleResponse(_ json: [String: Any]) async {
        // Check for auth response
        if let method = json["method"] as? String, method == "auth" {
            if let error = json["error"] as? [String: Any] {
                connectionState = .error(error["message"] as? String ?? "Authentication failed")
            } else {
                connectionState = .connected
                await refreshAllStatus()
            }
            return
        }

        // Handle status responses
        if let result = json["result"] {
            await parseStatusResult(result)
        }
    }

    private func handleEvent(_ json: [String: Any]) async {
        guard let event = json["event"] as? String else { return }

        switch event {
        case "gateway.status", "channel.updated", "model.updated", "cron.updated", "skill.updated", "agent.updated":
            await refreshAllStatus()
        default:
            break
        }
    }

    private func parseStatusResult(_ result: Any) async {
        // Parse based on known status structures
        if let dict = result as? [String: Any] {
            // Check if it's a runtime snapshot
            if let runtime = dict["runtime"] as? String {
                gatewayStatus = GatewayStatus(
                    version: dict["version"] as? String ?? "Unknown",
                    runtime: runtime,
                    uptime: dict["uptime"] as? Int,
                    rpcStatus: dict["rpcStatus"] as? String ?? "unknown",
                    channels: nil,
                    models: nil,
                    crons: nil,
                    skills: nil,
                    agents: nil
                )
            }
        }
    }

    // MARK: - Helpers
    private func generateMessageId() -> String {
        messageId += 1
        return "msg-\(messageId)-\(Date().timeIntervalSince1970)"
    }
}

// MARK: - AnyCodable Helper
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else {
            try container.encodeNil()
        }
    }
}
