import SwiftUI

struct ChannelsView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        Group {
            if let channels = gatewayService.gatewayStatus?.channels {
                if channels.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "No Channels",
                        message: "No channels configured"
                    )
                } else {
                    List {
                        ForEach(Array(channels.values)) { channel in
                            ChannelRow(channel: channel)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            } else {
                LoadingView(message: "Loading channels...")
            }
        }
        .navigationTitle("Channels")
        .refreshable {
            await gatewayService.requestChannelsStatus()
        }
    }
}

struct ChannelRow: View {
    let channel: ChannelStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: channelIcon)
                .font(.title2)
                .foregroundColor(channelColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(channel.name.capitalized)
                    .font(.headline)

                Text(channel.status.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Circle()
                .fill(channelColor)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }

    private var channelIcon: String {
        switch channel.name.lowercased() {
        case "telegram": return "paperplane.fill"
        case "feishu", "lark": return "message.fill"
        case "discord": return "bubble.left.and.bubble.right.fill"
        case "whatsapp": return "phone.fill"
        default: return "bubble.left.and.bubble.right"
        }
    }

    private var channelColor: Color {
        switch channel.status.lowercased() {
        case "connected": return .green
        case "disconnected": return .gray
        case "connecting": return .yellow
        case "error": return .red
        default: return .gray
        }
    }
}
