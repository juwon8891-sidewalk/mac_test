import Foundation
import RxDataSources

// MARK: - EmailVerificate
struct MyPageModel: Codable {
    let statusCode: Int
    let message: String
    let data: MyPageData
}

// MARK: - DataClass
struct MyPageData: Codable {
    let userID, identifierName, name: String
    let profileURL: String?
    let danceCount, followingCount, followerCount: Int
    let profileVideoURL: String?
    let boostCount: Int
    let isBlocked: Bool
    let isFollowed: Bool


    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case danceCount, followingCount, followerCount
        case profileVideoURL = "profileVideoUrl"
        case boostCount, isBlocked, isFollowed
    }
}
struct ProfileCollectionViewDataSection {
    var header: MyPageData
    var items: [Video]
}

extension ProfileCollectionViewDataSection: SectionModelType {
    typealias Item = Video
    
    init(original: ProfileCollectionViewDataSection, items: [Video]) {
        self = original
        self.items = items
    }
    
}


