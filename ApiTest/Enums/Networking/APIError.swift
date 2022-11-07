enum APIError: Error {
    case invalidUrl
    case errorDecode
    case failed(error: Error)
    case unknownError
    case noInternetConnection
    case tokenNotFound
    case accessDenied
//    case banned
    
    var description: String {
        switch self {
        case .accessDenied:
            return "access_denied"
        case .tokenNotFound:
            return "token not found"
        case .errorDecode:
            return "error decode"
        case .invalidUrl:
            return "invalid Url"
        case .failed(let error):
            return "failed \(error)"
        case .unknownError:
            return "unknown error"
        case .noInternetConnection:
            return "no internet connection"
        }
    }
}
