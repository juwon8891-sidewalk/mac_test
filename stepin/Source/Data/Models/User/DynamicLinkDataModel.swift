import Foundation

// MARK: - RankingDataModel
struct DynamicLinkDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: DynamicLinkData
}

// MARK: - DataClass
struct DynamicLinkData: Codable {
    let dynamiclink: String
}
