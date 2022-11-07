import UIKit
import Foundation

final class AlertManager {
    static let shared = AlertManager()
    
    func showAlert(coordinator: MainCoordinator?, title: String, message: String, preferredStyle: UIAlertController.Style) {
        guard let coordinator else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        coordinator.navigationController.children.last?.present(alert, animated: true)
    }
}
