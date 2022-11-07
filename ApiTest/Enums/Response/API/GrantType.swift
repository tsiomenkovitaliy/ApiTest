enum GrantType: String {
    case authorizationCode
    var rawValue: String {
        switch self {
        case .authorizationCode:
            return "authorization_code"
        }
    }
}
