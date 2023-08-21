import Foundation
import RxDataSources

struct SearchUserDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: SearchUserData
}

// MARK: - DataClass
struct SearchUserData: Codable {
    let userList: [UserList]
}

// MARK: - UserList
struct UserList: Codable {
    let userID, identifierName, name: String
    let profileURL: String?
    let followed, isBlocked: Bool

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case followed, isBlocked
    }
}


struct SearchUserCollectionViewDataSection {
    var items: [UserList]
}

extension SearchUserCollectionViewDataSection: SectionModelType {
    typealias Item = UserList
    
    init(original: SearchUserCollectionViewDataSection, items: [UserList]) {
        self = original
        self.items = items
    }
}
