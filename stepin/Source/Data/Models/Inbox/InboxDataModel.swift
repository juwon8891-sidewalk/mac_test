import Foundation
import RxDataSources

// MARK: - Welcome
struct InboxDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: InboxResultData
}

// MARK: - WelcomeData
struct InboxResultData: Codable {
    let inbox: [Inbox]
}

// MARK: - Inbox
struct Inbox: Codable {
    let inboxID, type: String
    let confirmed: Bool
    let data: InboxData
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case inboxID = "inboxId"
        case type, confirmed, data, createdAt
    }
}

// MARK: - InboxData
struct InboxData: Codable {
    let identifierName: String?
    let name: String?
    let profileURL: String?
    let text: String?
    let userId: String?
    let followed: Bool?
    let videoId: String?
    let commentId: String?
    let replyId: String?
    let shortformId: String?
    let danceId: String?
    let title: String?
    let rank: Int?
    let content: String?
    let achievementId: String?
    let compensation: Int?
    let acquired: Bool?
    let compensationAmount: Int?
    

    enum CodingKeys: String, CodingKey {
        case identifierName, name
        case profileURL = "profileUrl"
        case text
        case userId, followed, videoId, commentId, replyId, shortformId, danceId, title, rank, content, achievementId, compensation, acquired, compensationAmount
    }
}


struct InboxTableviewDataSection {
    var items: [Inbox]
}

extension InboxTableviewDataSection: SectionModelType {
    typealias Item = Inbox
    
    init(original: InboxTableviewDataSection, items: [Inbox]) {
        self = original
        self.items = items
    }
}
