import Foundation
import RxDataSources


struct BlockUserModel: Codable {
    let statusCode: Int
    let message: String
    let data: BlockUserData
}

struct BlockUserData: Codable {
    let blockList: [BlockList]
}

struct BlockList: Codable {
    let userID, identifierName, name: String
    let profileURL: String?
    var isBlocked: Bool

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case isBlocked
    }
}

struct BlockTableviewDataSection {
    var items: [BlockList]
}

extension BlockTableviewDataSection: SectionModelType {
    typealias Item = BlockList
    
    init(original: BlockTableviewDataSection, items: [BlockList]) {
        self = original
        self.items = items
    }
}
