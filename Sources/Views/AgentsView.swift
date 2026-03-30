import SwiftUI

struct AgentsView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        Group {
            if let agents = gatewayService.gatewayStatus?.agents {
                if agents.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Agents",
                        message: "No agents configured"
                    )
                } else {
                    List {
                        ForEach(agents) { agent in
                            AgentRow(agent: agent)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            } else {
                LoadingView(message: "Loading agents...")
            }
        }
        .navigationTitle("Agents")
        .refreshable {
            await gatewayService.requestAgentsStatus()
        }
    }
}

struct AgentRow: View {
    let agent: AgentStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(agent.isActive ? .blue : .gray)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(agent.name)
                    .font(.headline)

                if let model = agent.model {
                    Text(model)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(agent.status.capitalized)
                .font(.caption)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch agent.status.lowercased() {
        case "idle": return .gray
        case "working": return .blue
        case "paused": return .yellow
        case "error": return .red
        default: return .gray
        }
    }
}
