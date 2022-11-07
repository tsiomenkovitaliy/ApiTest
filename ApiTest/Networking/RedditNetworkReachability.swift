import Alamofire
import UIKit

final class RedditNetworkReachability {
    static let shared = RedditNetworkReachability()
    
    let reachabilityManager = NetworkReachabilityManager(host: "www.google.com")

    func startNetworkMonitoring(coordinator: MainCoordinator?) {
        reachabilityManager?.startListening { [weak self] status in
            guard let self else { return }
            
            let stateDiscription: String
            switch status {
            case .notReachable:
                stateDiscription = "Connection is lost"
            case .reachable:
                return
            case .unknown:
                stateDiscription = "Unknown network state"
            }
            
            AlertManager.shared.showAlert(coordinator: coordinator, title: self.reachabilityManager!.isReachable ? "Message" : "Error", message: stateDiscription, preferredStyle: .alert)
        }
    }
}

