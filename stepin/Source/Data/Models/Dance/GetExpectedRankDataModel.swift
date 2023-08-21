import Foundation

struct GetExpectedRankDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: GetExpectedRankData
}

// MARK: - DataClass
struct GetExpectedRankData: Codable {
    let myRank, expectedRank: Int?
}
