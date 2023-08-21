import Foundation

struct PatchLikeDanceDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: PatchLikeDanceData
}

// MARK: - DataClass
struct PatchLikeDanceData: Codable {
    let state: Int
}
