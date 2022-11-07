import Foundation
import Alamofire

protocol ServiceProtocol {
    func auth(completion: @escaping (Result<Bool, APIError>) -> Void)
    func getAccessToken(code: String, completion: @escaping (Result<Token, APIError>) -> Void)
    func getSubredditNew(_ searchText: String, link: String, completion: @escaping (Result<Subreddit, APIError>) -> Void)
    func errorHandler<T:Codable>(error: Error?, data: Data?, completion: @escaping (Result<T, APIError>) -> Void)
}

final class RedditService: ServiceProtocol {
    static let shared = RedditService()
    
    let retryLimit = 3
    
    private let clientId = "_eaosUfzCdUnihzXLhfD4A"
    private let state = UUID()
    private let redirectUrl = "at://auth_finish"
    private let subredditLimit = 30
    
    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForResource = 100
        configuration.waitsForConnectivity = true
        
        return Session(configuration: configuration)
    }()
    
    private var request: Alamofire.Request?
    private var token: Token!
    
    func auth(completion: @escaping (Result<Bool, APIError>) -> Void) {
        
        let queryItems = [URLQueryItem(name: "client_id", value: clientId),
                          URLQueryItem(name: "redirect_uri", value: redirectUrl),
                          URLQueryItem(name: "response_type", value: ResponseType.code.rawValue),
                          URLQueryItem(name: "scope", value: Scope.read.rawValue),
                          URLQueryItem(name: "duration", value: DuractionToken.temporary.rawValue),
                          URLQueryItem(name: "state", value: state.uuidString)
        ]
        
        var urlComponent = URLComponents(url: ApiEndpoint.auth.url, resolvingAgainstBaseURL: true)!
        urlComponent.queryItems = queryItems
        
        guard let url = urlComponent.url,
            UIApplication.shared.canOpenURL(url)
        else {
            completion(.failure(.invalidUrl))
            return
        }
        
        UIApplication.shared.open(url) { isComplite in
            completion(.success(isComplite))
        }
    }
    
    func getAccessToken(code: String, completion: @escaping (Result<Token, APIError>) -> Void) {
        
        let parameters: Parameters = ["grant_type":"authorization_code",
                                      "code":code,
                                      "redirect_uri": redirectUrl]
        
        request?.cancel()
        request = sessionManager.request(ApiEndpoint.accessToken.url,
                                         method: .post,
                                         parameters: parameters,
                                         interceptor: self)
            .authenticate(username: clientId, password: "")
            .response { [weak self] response in
                self?.errorHandler(error: response.error, data: response.data, completion: completion)
        }
    }
    
    func getSubredditNew(_ searchText: String, link: String, completion: @escaping (Result<Subreddit, APIError>) -> Void) {
        
        let parameters: Parameters = ["after" : link,
                                      "limit": subredditLimit]
        
        guard let accessToken = UserDefaultsManager.shared.getToken() else {
            completion(.failure(.tokenNotFound))
            return }
        
        request?.cancel()
        request = sessionManager.request(ApiEndpoint.subredditNew(subreddit:searchText).url,
                   method: .get,
                   parameters: parameters,
                   headers: HTTPHeaders(arrayLiteral: .authorization(bearerToken: accessToken)),
                                         interceptor: self)
        .response { [weak self] response in
            self?.errorHandler(error: response.error, data: response.data, completion: completion)
        }
    }
    
    func errorHandler<T:Codable>(error: Error?, data: Data?, completion: @escaping (Result<T, APIError>) -> Void) {
        
        if error != nil {
            print("dataTask error: \(error!.localizedDescription)")
            completion(.failure(.failed(error: error!)))
        } else if let data = data {
            do {
                let item = try JSONDecoder().decode(T.self, from: data)
                completion(.success(item))
            } catch {
                completion(.failure(.errorDecode))
            }
        } else {
            completion(.failure(.unknownError))
        }
    }
}
