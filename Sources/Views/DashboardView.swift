import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Connection Status Card
                ConnectionStatusCard()

                // Quick Stats Grid
                if gatewayService.connectionState == .connected {
                    QuickStatsGrid()

                    // Recent Activity
                    RecentActivityCard()
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await gatewayService.refreshAllStatus()
        }
    }
}

struct ConnectionStatusCard: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)

                Text(gatewayService.connectionState.description)
                    .font(.headline)

                Spacer()

                if gatewayService.connectionState != .connected {
                    Button(action: {
                        Task {
                            await gatewayService.connect()
                        }
                    }) {
                        Label("Connect", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: {
                        gatewayService.disconnect()
                    }) {
                        Label("Disconnect", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }

            if let error = gatewayService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            if let status = gatewayService.gatewayStatus {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    LabeledContent("Version", value: status.version)
                    LabeledContent("Runtime", value: status.runtime)
                    LabeledContent("RPC Status", value: status.rpcStatus)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch gatewayService.connectionState {
        case .connected: return .green
        case .connecting, .authenticating: return .yellow
        case .disconnected: return .gray
        case .error: return .red
        }
    }
}

struct QuickStatsGrid: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Channels",
                value: "\(gatewayService.gatewayStatus?.channels?.count ?? 0)",
                icon: "bubble.left.and.bubble.right",
                color: .blue
            )

            StatCard(
                title: "Models",
                value: "\(gatewayService.gatewayStatus?.models?.count ?? 0)",
                icon: "brain.head.profile",
                color: .purple
            )

            StatCard(
                title: "Cron Jobs",
                value: "\(gatewayService.gatewayStatus?.crons?.count ?? 0)",
                icon: "clock",
                color: .orange
            )

            StatCard(
                title: "Skills",
                value: "\(gatewayService.gatewayStatus?.skills?.count ?? 0)",
                icon: "square.stack.3d.up",
                color: .green
            )

            StatCard(
                title: "Agents",
                value: "\(gatewayService.gatewayStatus?.agents?.count ?? 0)",
                icon: "person.2",
                color: .pink
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct RecentActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)

            Text("No recent activity")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
