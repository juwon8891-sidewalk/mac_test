import Foundation
import RxDataSources

struct NormalVideoCollectionViewDataSection {
    var items: [Video]
}

extension NormalVideoCollectionViewDataSection: SectionModelType {
    typealias Item = Video
    
    init(original: NormalVideoCollectionViewDataSection, items: [Video]) {
        self = original
        self.items = items
    }
}

