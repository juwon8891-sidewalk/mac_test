import Foundation
import RxDataSources

struct HotDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: HotData
}

struct HotData: Codable {
    let video: [Video]
}

// MARK: - Video
struct VideoData: Codable {
    let userID, danceID, videoID, identifierName: String
    let name: String
    let profileURL: String?
    let artist: String
    let title: String
    let coverURL: String
    let hashtag: [Hashtag]
    let score: String
    let openScore: Bool
    let content: String
    let allowComment: Bool
    let commentCount, likeCount: Int
    let videoURL: String?
    let thumbnailURL: String?
    let alreadyLiked: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case danceID = "danceId"
        case videoID = "videoId"
        case identifierName, name
        case profileURL = "profileUrl"
        case artist, title
        case coverURL = "coverUrl"
        case hashtag, score, openScore, content, allowComment, commentCount, likeCount
        case videoURL = "videoUrl"
        case thumbnailURL = "thumbnailUrl"
        case alreadyLiked, createdAt
    }
}
struct HotCollectionViewDataSection {
    var items: [Video]
}

extension HotCollectionViewDataSection: SectionModelType {
    typealias Item = Video
    
    init(original: HotCollectionViewDataSection, items: [Video]) {
        self = original
        self.items = items
    }
}
