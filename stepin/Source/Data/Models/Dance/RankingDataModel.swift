import Foundation
import RxDataSources
// MARK: - RankingDataModel
struct RankingDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: RankModel
}

// MARK: - DataClass
struct RankModel: Codable {
    let danceRankList: [DanceRankList]
}

// MARK: - DanceRankList
struct DanceRankList: Codable {
    let userID, identifierName, name: String
    let profileURL: String?
    let score: String
    let rank: Int
    let videoID: String
    let isBlock: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case score, rank
        case videoID = "videoId"
        case isBlock
    }
}

struct RankingTableviewDataSection {
    var items: [DanceRankList]
}

extension RankingTableviewDataSection: SectionModelType {
    typealias Item = DanceRankList
    
    init(original: RankingTableviewDataSection, items: [DanceRankList]) {
        self = original
        self.items = items
    }
}
