import Foundation
import RxDataSources

struct SearchHashTagDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: SearchHashTagData
}

// MARK: - DataClass
struct SearchHashTagData: Codable {
    let hashtag: [Hashtag]
}

struct SearchHashTagCollectionViewDataSection {
    var items: [Hashtag]
}

extension SearchHashTagCollectionViewDataSection: SectionModelType {
    typealias Item = Hashtag
    
    init(original: SearchHashTagCollectionViewDataSection, items: [Hashtag]) {
        self = original
        self.items = items
    }
}
