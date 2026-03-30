import SwiftUI

struct SkillsView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService

    var body: some View {
        Group {
            if let skills = gatewayService.gatewayStatus?.skills {
                if skills.isEmpty {
                    EmptyStateView(
                        icon: "square.stack.3d.up",
                        title: "No Skills",
                        message: "No skills installed"
                    )
                } else {
                    List {
                        ForEach(skills) { skill in
                            SkillRow(skill: skill)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            } else {
                LoadingView(message: "Loading skills...")
            }
        }
        .navigationTitle("Skills")
        .refreshable {
            await gatewayService.requestSkillsStatus()
        }
    }
}

struct SkillRow: View {
    let skill: SkillStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(skill.name)
                    .font(.headline)

                if let version = skill.version {
                    Text("v\(version)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if skill.enabled {
                Text("Active")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("Disabled")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
