import Foundation
import RxDataSources

struct FollowerModel: Codable {
    let statusCode: Int
    let message: String
    let data: FollowerData
}

struct FollowerData: Codable {
    let followerList: [FollowerList]
}

struct FollowerList: Codable {
    let followID, userID, identifierName, name: String
    let profileURL: String?
    var followed: Bool
    
    enum CodingKeys: String, CodingKey {
        case followID = "followId"
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case followed
    }
}

struct FollowerTableviewDataSection {
    var items: [FollowerList]
}

extension FollowerTableviewDataSection: SectionModelType {
    typealias Item = FollowerList
    
    init(original: FollowerTableviewDataSection, items: [FollowerList]) {
        self = original
        self.items = items
    }
}
