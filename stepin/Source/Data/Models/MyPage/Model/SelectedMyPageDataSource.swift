import Foundation
import RxDataSources

struct SelectedVideoCollectionViewDataSection {
    var items: [Video]
}

extension SelectedVideoCollectionViewDataSection: SectionModelType {
    typealias Item = Video
    
    init(original: SelectedVideoCollectionViewDataSection, items: [Video]) {
        self = original
        self.items = items
    }
}

