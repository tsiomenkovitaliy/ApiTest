struct SubredditData: Codable {
    let after: String?
    let dist: Int?
    let geoFilter: String?
    let children: [Child]?
    let modhash,before: String?

    enum CodingKeys: String, CodingKey {
        case after, dist, modhash
        case geoFilter = "geo_filter"
        case children, before
    }
}
