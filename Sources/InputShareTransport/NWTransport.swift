import Foundation
import Network

public enum NWTransport {
    private static func makeTCPParams() -> NWParameters {
        let tcp = NWProtocolTCP.Options()
        tcp.noDelay = true                    // disable Nagle — send immediately
        tcp.connectionTimeout = 5             // 5s connect timeout
        return NWParameters(tls: nil, tcp: tcp)
    }

    public static func makeClientConnection(host: String, port: UInt16) -> NWConnection {
        let params = makeTCPParams()
        return NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: params)
    }

    public static func makeListener(port: UInt16) throws -> NWListener {
        let params = makeTCPParams()
        return try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
    }

    /// TCP params for Bonjour / endpoint connections
    public static var tcpParameters: NWParameters {
        makeTCPParams()
    }
}
