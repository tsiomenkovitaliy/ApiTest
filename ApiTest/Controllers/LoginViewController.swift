//
//  LoginViewController.swift
//  ApiTest
//
//  Created by Vitalii Tsiomenko on 03.11.2022.
//

import UIKit

final class LoginViewController: UIViewController, Storyboarded {

    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RedditNetworkReachability.shared
            .startNetworkMonitoring(coordinator: coordinator)
    }
    
    @IBAction private func loginReddit(_ sender: Any) {
        RedditService.shared.auth { [weak self] result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                AlertManager.shared.showAlert(coordinator: self?.coordinator,
                                              title: "Error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
            }
        }
    }
}
