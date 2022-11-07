import Foundation

final class UserDefaultsManager {
    
    enum Key: String {
        case token
    }
    
    static let shared: UserDefaultsManager = {
        return UserDefaultsManager()
    }()
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: Key.token.rawValue)
    }
    func setToken(token: String) {
        UserDefaults.standard.set(token, forKey: Key.token.rawValue)
        UserDefaults.standard.synchronize()
    }
}
