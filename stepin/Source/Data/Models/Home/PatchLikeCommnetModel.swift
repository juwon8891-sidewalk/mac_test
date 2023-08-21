import Foundation

struct PatchLikeCommentModel: Codable {
    let statusCode: Int
    let message: String
    let data: LikeCommentData
}

struct LikeCommentData: Codable {
    let state: Int
}
