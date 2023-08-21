import Foundation

struct LikeVideoDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: LikeVideoData
}

struct LikeVideoData: Codable {
    let state: Int
}
