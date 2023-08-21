import Foundation
import RxDataSources

// MARK: - SuperShortformDataModel
struct SuperShortformDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: SuperShortFormData
}

// MARK: - DataClass
struct SuperShortFormData: Codable {
    let newSuperShortform: [SuperShortform]
}

// MARK: - SuperShortform
struct SuperShortform: Codable, ViewItemData {
    let id, type: String
    let totalTime: Double
    let videoUrl: String
    let thumbnailUrl: String?
    let section: [Section]
    let video: [Video]
}

// MARK: - Section
struct Section: Codable {
    let start, end: Float
}

// MARK: - Video
struct Video: Codable {
    let userID, danceID, videoID: String
    let identifierName, name: String
    let profileURL: String?
    let artist: String
    let title: String
    let coverURL: String
    let hashtag: [Hashtag]
    let score: String
    let openScore: Bool
    let content: String
    let allowComment: Bool
    var commentCount, likeCount: Int
    let videoURL: String?
    let thumbnailURL: String?
    var alreadyLiked: Bool
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

// MARK: - Hashtag
struct Hashtag: Codable {
    let id: String
    let keyword: String
}

protocol ViewItemData {
    
}

struct SuperShortFormCollectionViewDataSection: ViewItemData {
    var items: [SuperShortform]
}

extension SuperShortFormCollectionViewDataSection: SectionModelType {
    typealias Item = SuperShortform
    
    init(original: SuperShortFormCollectionViewDataSection, items: [SuperShortform]) {
        self = original
        self.items = items
    }
    
}
