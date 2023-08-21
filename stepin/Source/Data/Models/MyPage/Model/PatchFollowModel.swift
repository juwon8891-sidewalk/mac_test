import Foundation

struct PatchFollowModel: Codable {
    let statusCode: Int
    let message: String
    let data: PatchfollowData
}

// MARK: - DataClass
struct PatchfollowData: Codable {
    let state: Int
}
