// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let rankingDataModel = try? JSONDecoder().decode(RankingDataModel.self, from: jsonData)

import Foundation

struct PlaySessionDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: PlaySessionDataClass
}

// MARK: - DataClass
struct PlaySessionDataClass: Codable {
    let playSessionData: PlaySessionData?
    let playDanceData: PlaySessionDanceData
}

// MARK: - PlayDanceData
struct PlaySessionDanceData: Codable {
    let danceID, title, artist: String
    let startTime: Float
    let endTime: Float
    let coverURL: String
    let musicURL: String
    let guideURL: String?
    let outlineUrl: String?

    enum CodingKeys: String, CodingKey {
        case danceID = "danceId"
        case title, artist, startTime, endTime
        case coverURL = "coverUrl"
        case musicURL = "musicUrl"
        case guideURL = "guideUrl"
        case outlineUrl = "outlineUrl"
    }
}

// MARK: - PlaySessionData
struct PlaySessionData: Codable {
    let sessionID, token: String?

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case token
    }
}


struct MakePlaySessionRequestBody: Codable {
    var danceId: String
    var gameType: String
    
    init(danceId: String, gameType: String) {
        self.danceId = danceId
        self.gameType = gameType
    }
}
