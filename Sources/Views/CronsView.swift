import SwiftUI

struct CronsView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        Group {
            if let crons = gatewayService.gatewayStatus?.crons {
                if crons.isEmpty {
                    EmptyStateView(
                        icon: "clock",
                        title: "No Cron Jobs",
                        message: "No scheduled tasks configured"
                    )
                } else {
                    List {
                        ForEach(crons) { cron in
                            CronRow(cron: cron)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            } else {
                LoadingView(message: "Loading cron jobs...")
            }
        }
        .navigationTitle("Cron Jobs")
        .refreshable {
            await gatewayService.requestCronsStatus()
        }
    }
}

struct CronRow: View {
    let cron: CronStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(cron.cronId)
                    .font(.headline)

                Text(cron.schedule)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(cron.status.capitalized)
                    .font(.caption)
                    .foregroundColor(statusColor)

                if let lastRun = cron.lastRun {
                    Text(lastRun)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch cron.status.lowercased() {
        case "scheduled": return .blue
        case "running": return .yellow
        case "completed": return .green
        case "failed": return .red
        case "disabled": return .gray
        default: return .gray
        }
    }
}
