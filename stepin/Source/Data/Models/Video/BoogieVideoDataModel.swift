import Foundation
import RxDataSources

struct BoogieVideoDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: BoogieVideoData
}

// MARK: - DataClass
struct BoogieVideoData: Codable {
    let video: [Video]
}

struct BoogieVideoCollectionViewDataSection {
    var items: [Video]
}

extension BoogieVideoCollectionViewDataSection: SectionModelType {
    typealias Item = Video
    
    init(original: BoogieVideoCollectionViewDataSection, items: [Video]) {
        self = original
        self.items = items
    }
}

