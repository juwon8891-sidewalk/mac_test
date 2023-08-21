import Foundation
import RxDataSources

struct SearchHotVideoDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: SearchHotVideoData
}

struct SearchHotVideoData: Codable {
    let video: [Video]
}

struct SearchHotVideoCollectionViewDataSection {
    var items: [Video]
}

extension SearchHotVideoCollectionViewDataSection: SectionModelType {
    typealias Item = Video
    
    init(original: SearchHotVideoCollectionViewDataSection, items: [Video]) {
        self = original
        self.items = items
    }
}

