import Foundation
import RxDataSources

// MARK: - ReplyCommentDataModel
struct ReplyCommentDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: ReplyCommentData
}

// MARK: - DataClass
struct ReplyCommentData: Codable {
    let reply: [Reply]
    let comment: Comment
}

// MARK: - Reply
struct Reply: Codable {
    let commentID, userID, identifierName, name: String
    let profileURL: String?
    let content: String
    var likeCount: Int
    var alreadyLiked, alreadyBlocked: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case commentID = "commentId"
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case content, likeCount, alreadyLiked, alreadyBlocked, createdAt
    }
}
struct ReplyCommentTableviewDataSection {
    var header: Comment
    var items: [Reply]
}

extension ReplyCommentTableviewDataSection: SectionModelType {
    typealias Item = Reply
    
    init(original: ReplyCommentTableviewDataSection, items: [Reply]) {
        self = original
        self.items = items
    }
}
