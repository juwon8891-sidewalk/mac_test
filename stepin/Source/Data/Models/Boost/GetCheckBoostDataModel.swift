import Foundation

struct GetCheckBoostDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: GetCheckBoostData
}

struct GetCheckBoostData: Codable {
    let possible: Bool
}
