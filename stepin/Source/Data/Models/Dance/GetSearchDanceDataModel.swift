import Foundation
import RxDataSources

struct GetSearchDanceDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: GetSearchDanceData
}

// MARK: - DataClass
struct GetSearchDanceData: Codable {
    let dance: [Dance]
}

// MARK: - Dance
struct Dance: Codable {
    let danceID, artist, title, coverURL: String

    enum CodingKeys: String, CodingKey {
        case danceID = "danceId"
        case artist, title
        case coverURL = "coverUrl"
    }
}


//Data Section
struct SearchDanceListCollectionViewDataSection {
    var items: [Dance]
}

extension SearchDanceListCollectionViewDataSection: SectionModelType {
    typealias Item = Dance
    
    init(original: SearchDanceListCollectionViewDataSection, items: [Dance]) {
        self = original
        self.items = items
    }
}
