import Foundation

struct MyPageVideoDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: MyPageVideoData
}

// MARK: - DataClass
struct MyPageVideoData: Codable {
    let video: [Video]
}
