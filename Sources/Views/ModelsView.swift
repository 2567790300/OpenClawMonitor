import SwiftUI

struct ModelsView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        Group {
            if let models = gatewayService.gatewayStatus?.models {
                if models.isEmpty {
                    EmptyStateView(
                        icon: "brain.head.profile",
                        title: "No Models",
                        message: "No models configured"
                    )
                } else {
                    List {
                        ForEach(models) { model in
                            ModelRow(model: model)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            } else {
                LoadingView(message: "Loading models...")
            }
        }
        .navigationTitle("Models")
        .refreshable {
            await gatewayService.requestModelsStatus()
        }
    }
}

struct ModelRow: View {
    let model: ModelStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(model.modelId)
                        .font(.headline)

                    if model.isPrimary == true {
                        Text("Primary")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }

                Text(model.provider)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(model.status.capitalized)
                .font(.caption)
                .foregroundColor(statusColor)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch model.status.lowercased() {
        case "available": return .green
        case "unavailable": return .red
        case "loading": return .yellow
        default: return .gray
        }
    }
}
