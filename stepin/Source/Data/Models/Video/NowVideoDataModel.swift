import Foundation

struct NowVideoDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: NowVideoData
}

// MARK: - DataClass
struct NowVideoData: Codable {
    let video: [Video]
}
