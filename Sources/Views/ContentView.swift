import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case channels = "Channels"
        case models = "Models"
        case crons = "Crons"
        case skills = "Skills"
        case agents = "Agents"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .channels: return "bubble.left.and.bubble.right.fill"
            case .models: return "brain.head.profile"
            case .crons: return "clock.fill"
            case .skills: return "square.stack.3d.up.fill"
            case .agents: return "person.2.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon)
                    }
                    .tag(Tab.dashboard)

                ChannelsView()
                    .tabItem {
                        Label(Tab.channels.rawValue, systemImage: Tab.channels.icon)
                    }
                    .tag(Tab.channels)

                ModelsView()
                    .tabItem {
                        Label(Tab.models.rawValue, systemImage: Tab.models.icon)
                    }
                    .tag(Tab.models)

                CronsView()
                    .tabItem {
                        Label(Tab.crons.rawValue, systemImage: Tab.crons.icon)
                    }
                    .tag(Tab.crons)

                SkillsView()
                    .tabItem {
                        Label(Tab.skills.rawValue, systemImage: Tab.skills.icon)
                    }
                    .tag(Tab.skills)

                AgentsView()
                    .tabItem {
                        Label(Tab.agents.rawValue, systemImage: Tab.agents.icon)
                    }
                    .tag(Tab.agents)

                SettingsView()
                    .tabItem {
                        Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                    }
                    .tag(Tab.settings)
            }
            .navigationTitle(selectedTab.rawValue)
        }
    }
}
