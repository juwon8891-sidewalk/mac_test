import Foundation

struct GetHashTagDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: GetHashTagData
}

// MARK: - DataClass
struct GetHashTagData: Codable {
    let hashtag: Hashtag
}
