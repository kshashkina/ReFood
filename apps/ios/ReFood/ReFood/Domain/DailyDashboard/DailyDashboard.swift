import Foundation

public struct DailyDashboardResponse: Codable {
    public let dateUtc: String
    public let tip: DailyTip
    public let news: [DailyNews]
    
    enum CodingKeys: String, CodingKey {
        case dateUtc = "date_utc"
        case tip
        case news
    }
}

public struct DailyTip: Codable {
    public let tipDate: String
    public let adviceEn: String
    public let adviceUa: String
    
    enum CodingKeys: String, CodingKey {
        case tipDate = "tip_date"
        case adviceEn = "advice_en"
        case adviceUa = "advice_ua"
    }
}

public struct DailyNews: Codable, Identifiable {
    public let id: String
    public let date: String
    public let resource: String
    public let link: String
    public let newsType: String
    
    public let simplifiedTitleUa: String?
    public let simplifiedTitleEn: String?
    public let takeawayUa: String?
    public let takeawayEn: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, resource, link
        case newsType = "news_type"
        case simplifiedTitleUa = "simplified_title_ua"
        case simplifiedTitleEn = "simplified_title_en"
        case takeawayUa = "takeaway_ua"
        case takeawayEn = "takeaway_en"
    }
}
