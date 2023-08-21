import Foundation

struct DanceInfoDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: DanceInfoData
}

// MARK: - DataClass
struct DanceInfoData: Codable {
    let danceID, title, artist: String
    let musicURL: String
    let startTime, endTime: Double
    let coverURL: String

    enum CodingKeys: String, CodingKey {
        case danceID = "danceId"
        case title, artist
        case musicURL = "musicUrl"
        case startTime, endTime
        case coverURL = "coverUrl"
    }
}
