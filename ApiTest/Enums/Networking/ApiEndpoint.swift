import Foundation

enum ApiEndpoint {
    static let redditHost = "https://www.reddit.com/"
    static let authHost = "https://oauth.reddit.com/"
    
    case auth
    case accessToken
    case subredditNew(subreddit:String)
    
    var url: URL {
        switch self {
        case .auth:
            return URL(string:"\(ApiEndpoint.redditHost)api/v1/authorize.compact")!
        case .accessToken:
            return URL(string:"\(ApiEndpoint.redditHost)api/v1/access_token")!
        case .subredditNew(let subreddit) :
            return URL(string:"\(ApiEndpoint.authHost)r/\(subreddit)/new")!
        }
    }
}
