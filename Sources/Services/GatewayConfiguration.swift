import Foundation

struct GatewayConfiguration {
    var host: String
    var port: Int
    var token: String

    static let `default` = GatewayConfiguration(
        host: "127.0.0.1",
        port: 18790,
        token: "19dac224657ce51af8e3860ae932d649cd00a65856ccec52"
    )

    var webSocketURL: String {
        "ws://\(host):\(port)"
    }

    var httpURL: String {
        "http://\(host):\(port)"
    }
}

class ConfigurationManager: ObservableObject {
    @Published var configuration: GatewayConfiguration

    private let userDefaultsKey = "openclaw_gateway_config"

    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let config = try? JSONDecoder().decode(GatewayConfiguration.self, from: data) {
            self.configuration = config
        } else {
            self.configuration = .default
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func update(host: String, port: Int, token: String) {
        configuration.host = host
        configuration.port = port
        configuration.token = token
        save()
    }
}

extension GatewayConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case host, port, token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        host = try container.decode(String.self, forKey: .host)
        port = try container.decode(Int.self, forKey: .port)
        token = try container.decode(String.self, forKey: .token)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(host, forKey: .host)
        try container.encode(port, forKey: .port)
        try container.encode(token, forKey: .token)
    }
}
