import Foundation

// MARK: - Gateway Status
struct GatewayInfo: Codable, Identifiable {
    var id: String { "gateway" }
    let version: String
    let runtime: RuntimeState
    let uptimeSeconds: Int?
    let rpcStatus: RPCStatus
    let services: [ServiceInfo]?

    enum RuntimeState: String, Codable {
        case running
        case stopped
        case starting
        case unknown
    }

    enum RPCStatus: String, Codable {
        case ok
        case error
        case unknown
    }

    struct ServiceInfo: Codable, Identifiable {
        var id: String { name }
        let name: String
        let status: String
        let type: String?
    }

    var uptimeFormatted: String {
        guard let seconds = uptimeSeconds else { return "Unknown" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Channel Status
struct Channel: Codable, Identifiable {
    var id: String { "\(provider)-\(accountId ?? "default")" }
    let provider: String
    let accountId: String?
    let displayName: String
    let status: ChannelStatus
    let enabled: Bool
    let connectedAt: Date?
    let messageCount: Int?

    enum ChannelStatus: String, Codable {
        case connected
        case disconnected
        case connecting
        case error
        case unknown
    }

    var statusColor: String {
        switch status {
        case .connected: return "green"
        case .disconnected: return "gray"
        case .connecting: return "yellow"
        case .error: return "red"
        case .unknown: return "gray"
        }
    }
}

// MARK: - Model Status
struct Model: Codable, Identifiable {
    var id: String { "\(provider)-\(modelId)" }
    let provider: String
    let modelId: String
    let displayName: String
    let status: ModelStatus
    let isPrimary: Bool
    let contextWindow: Int?
    let inputCost: Double?
    let outputCost: Double?

    enum ModelStatus: String, Codable {
        case available
        case unavailable
        case loading
        case error
    }
}

// MARK: - Cron Job Status
struct CronJob: Codable, Identifiable {
    var id: String { cronId }
    let cronId: String
    let schedule: String
    let description: String?
    let lastRun: CronRun?
    let nextRun: Date?
    let status: CronStatus
    let enabled: Bool

    enum CronStatus: String, Codable {
        case scheduled
        case running
        case completed
        case failed
        case disabled
    }

    struct CronRun: Codable {
        let startTime: Date
        let endTime: Date?
        let status: String
        let result: String?
    }
}

// MARK: - Skill Status
struct Skill: Codable, Identifiable {
    var id: String { skillId }
    let skillId: String
    let name: String
    let description: String?
    let version: String?
    let enabled: Bool
    let status: SkillStatus
    let installedAt: Date?

    enum SkillStatus: String, Codable {
        case active
        case inactive
        case error
        case unknown
    }
}

// MARK: - Agent Status
struct Agent: Codable, Identifiable {
    var id: String { agentId }
    let agentId: String
    let name: String
    let model: String?
    let status: AgentStatus
    let isActive: Bool
    let sessionCount: Int?
    let lastActivity: Date?

    enum AgentStatus: String, Codable {
        case idle
        case working
        case paused
        case error
        case unknown
    }
}

// MARK: - Session Info
struct Session: Codable, Identifiable {
    var id: String { sessionId }
    let sessionId: String
    let agentId: String?
    let channel: String?
    let messageCount: Int
    let createdAt: Date
    let lastMessageAt: Date
    let status: SessionStatus

    enum SessionStatus: String, Codable {
        case active
        case archived
        case deleted
    }
}
