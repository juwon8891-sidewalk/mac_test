import Foundation

struct UploadVideoDataModel: Codable {
    let statusCode: Int?
    let message: String
    let data: UploadVideoData
}

// MARK: - DataClass
struct UploadVideoData: Codable {
    let signedURL: [SignedURL]

    enum CodingKeys: String, CodingKey {
        case signedURL = "signedUrl"
    }
}



/**
 request Body
 */
struct PostVideoRequestBody: Codable {
    private var danceId: String
    private var score: String
    private var content: String
    private var hashtag: [String]
    private var allowComment: Bool
    private var oepnScore: Bool
    private var gameType: String
    private var sessionId: String
    
    init(danceId: String,
         score: String,
         content: String,
         hashtag: [String],
         allowComment: Bool,
         openScore: Bool,
         gameType: String,
         sessionId: String) {
        self.danceId = danceId
        self.score = score
        self.content = content
        self.hashtag = hashtag
        self.allowComment = allowComment
        self.oepnScore = openScore
        self.gameType = gameType
        self.sessionId = sessionId
    }
}
