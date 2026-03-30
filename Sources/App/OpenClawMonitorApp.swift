import SwiftUI

@main
struct OpenClawMonitorApp: App {
    @StateObject private var gatewayService = OpenClawGatewayService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gatewayService)
        }
    }
}
