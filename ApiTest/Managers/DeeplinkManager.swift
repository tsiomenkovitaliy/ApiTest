import Foundation

protocol DeeplinkManagerProtocol {
    func manage(url: URL, completion: @escaping (Result<DeepLinkParameters, APIError>) -> Void)
}

final class DeeplinkManager {
    
    static let shared = DeeplinkManager()
    
    func manage(url: URL, completion: @escaping (Result<DeepLinkParameters, APIError>) -> Void) {
        guard url.scheme == DeepLinkConstants.scheme,
              url.host == DeepLinkConstants.host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems
        else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let query = queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        if let error = query[DeepLinkConstants.error] {
            if error == APIError.accessDenied.description {
                completion(.failure(.accessDenied))
            } else {
                completion(.failure(.unknownError))
            }
            return
        }
        
        guard let code = query[DeepLinkConstants.code],
              let state = query[DeepLinkConstants.state]
        else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let parameters = DeepLinkParameters(state: state, code: code)
        
        completion(.success(parameters))
    }
}
