import Foundation

struct GetVideoInfoDataModel: Codable {
    let statusCode: Int?
    let message: String
    let data: GetVideoInfoData
}

struct GetVideoInfoData: Codable {
    let video: Video
}
