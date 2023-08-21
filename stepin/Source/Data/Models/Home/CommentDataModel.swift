import Foundation
import RxDataSources

// MARK: - SuperShortformDataModel
struct CommentDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: CommentData
}

// MARK: - DataClass
struct CommentData: Codable {
    let comment: [Comment]
}

// MARK: - Comment
struct Comment: Codable {
    let commentID, userID: String
    let identifierName: String
    let name: String
    let profileURL: String?
    let content: String
    var likeCount, replyCount: Int
    var alreadyLiked, alreadyBlocked: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case commentID = "commentId"
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case content, likeCount, replyCount, alreadyLiked, alreadyBlocked, createdAt
    }
}
struct CommentTableviewDataSection {
    var items: [Comment]
}

extension CommentTableviewDataSection: SectionModelType {
    typealias Item = Comment
    
    init(original: CommentTableviewDataSection, items: [Comment]) {
        self = original
        self.items = items
    }
}
