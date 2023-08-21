import Foundation
import RxDataSources

struct FollowingModel: Codable {
    let statusCode: Int
    let message: String
    let data: FollowingData
}

struct FollowingData: Codable {
    let followingList: [FollowingList]
}

struct FollowingList: Codable {
    let userID, identifierName, name: String
    let profileURL: String?
    var followed: Bool

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case followed
    }
}

struct FollowingTableviewDataSection {
    var items: [FollowingList]
}

extension FollowingTableviewDataSection: SectionModelType {
    typealias Item = FollowingList
    
    init(original: FollowingTableviewDataSection, items: [FollowingList]) {
        self = original
        self.items = items
    }
}
