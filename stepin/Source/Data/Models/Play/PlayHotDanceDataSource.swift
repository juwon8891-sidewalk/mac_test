import Foundation
import RxDataSources

struct PlayDanceDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: PlayDanceData
}

// MARK: - DataClass
struct PlayDanceData: Codable {
    let dance: [PlayDance]
}

// MARK: - Dance
struct PlayDance: Codable {
    let danceID, artist, title: String
    let musicURL: String
    let coverURL: String
    let alreadyLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case danceID = "danceId"
        case artist, title
        case musicURL = "musicUrl"
        case coverURL = "coverUrl"
        case alreadyLiked
    }
}


//Data Section
struct PlayDanceTableViewDataSection {
    var items: [PlayDance]
}

extension PlayDanceTableViewDataSection: SectionModelType {
    typealias Item = PlayDance
    
    init(original: PlayDanceTableViewDataSection, items: [PlayDance]) {
        self = original
        self.items = items
    }
}
