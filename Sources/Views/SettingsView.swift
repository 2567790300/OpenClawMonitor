import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gatewayService: OpenClawGatewayService
    @StateObject private var configManager = ConfigurationManager()

    @State private var host: String = ""
    @State private var port: String = ""
    @State private var token: String = ""
    @State private var showingSaveAlert = false

    var body: some View {
        Form {
            Section("Gateway Connection") {
                TextField("Host", text: $host)
                    .textContentType(.URL)
                    .autocapitalization(.none)

                TextField("Port", text: $port)
                    .keyboardType(.numberPad)

                SecureField("Token", text: $token)
            }

            Section {
                Button("Save Configuration") {
                    saveConfiguration()
                }
                .disabled(host.isEmpty || port.isEmpty || token.isEmpty)
            }

            Section("Current Status") {
                LabeledContent("Connection", value: gatewayService.connectionState.description)

                if let status = gatewayService.gatewayStatus {
                    LabeledContent("Version", value: status.version)
                    LabeledContent("Runtime", value: status.runtime)
                }
            }

            Section("Actions") {
                Button(action: {
                    Task {
                        if gatewayService.connectionState == .connected {
                            gatewayService.disconnect()
                        }
                        await gatewayService.connect()
                    }
                }) {
                    Label(
                        gatewayService.connectionState == .connected ? "Reconnect" : "Connect",
                        systemImage: "arrow.clockwise"
                    )
                }

                Button(action: {
                    Task {
                        await gatewayService.refreshAllStatus()
                    }
                }) {
                    Label("Refresh All Status", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(gatewayService.connectionState != .connected)
            }

            Section("About") {
                LabeledContent("App Version", value: "1.0.0")
                LabeledContent("OpenClaw SDK", value: "2026.3.28")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            loadConfiguration()
        }
        .alert("Configuration Saved", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Gateway configuration has been saved.")
        }
    }

    private func loadConfiguration() {
        host = configManager.configuration.host
        port = String(configManager.configuration.port)
        token = configManager.configuration.token
    }

    private func saveConfiguration() {
        guard let portNumber = Int(port) else { return }
        configManager.update(host: host, port: portNumber, token: token)

        // Reinitialize gateway service with new config
        let newConfig = GatewayConfiguration(host: host, port: portNumber, token: token)
        gatewayService.disconnect()
        // Note: In a real app, you'd pass this config to the service
        // For now, we update UserDefaults and the user can reconnect

        showingSaveAlert = true
    }
}
