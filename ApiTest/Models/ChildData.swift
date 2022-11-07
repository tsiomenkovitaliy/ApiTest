struct ChildData: Codable {
    let title, url: String?
    let subredditID: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case url
        case subredditID = "subreddit_id"
    }
}
