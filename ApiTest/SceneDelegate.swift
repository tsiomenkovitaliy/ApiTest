//
//  SceneDelegate.swift
//  ApiTest
//
//  Created by Vitalii Tsiomenko on 01.11.2022.
//

import UIKit
import Alamofire

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navController = UINavigationController()
        coordinator = MainCoordinator(navigationController: navController)
        coordinator?.start()

        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url
        else {
            AlertManager.shared.showAlert(coordinator: coordinator, title: "Error", message: "Bed parameters", preferredStyle: .alert)
            return
        }
        
        DeeplinkManager.shared.manage(url: url) { result in
            switch result {
            case .success(let parameters):
                RedditService.shared.getAccessToken(code: parameters.code) { [weak self] result in
                    guard let self else { return }
                    
                    switch result {
                    case .success(let token):
                        UserDefaultsManager.shared.setToken(token: token.accessToken)
                        self.coordinator?.subredditView()
                    case .failure(let error):
                        AlertManager.shared.showAlert(coordinator: self.coordinator, title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    }
                }
            case .failure(let error):
                AlertManager.shared.showAlert(coordinator: self.coordinator, title: "Error", message: error.description, preferredStyle: .alert)
            }
        }
    }
}
