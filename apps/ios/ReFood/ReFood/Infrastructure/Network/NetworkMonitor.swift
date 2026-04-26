import Network
import Foundation

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var continuations: [CheckedContinuation<Bool, Never>] = []
    
    private(set) var isConnected: Bool = false
    private(set) var isReady: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            let connected = path.status == .satisfied
            
            self.isConnected = connected
            self.isReady = true
            
            let continuations = self.continuations
            self.continuations.removeAll()
            
            continuations.forEach { continuation in
                continuation.resume(returning: connected)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func waitForConnectionStatus() async -> Bool {
        if isReady {
            return isConnected
        }
        
        return await withCheckedContinuation { continuation in
            queue.async {
                if self.isReady {
                    continuation.resume(returning: self.isConnected)
                } else {
                    self.continuations.append(continuation)
                }
            }
        }
    }
}
