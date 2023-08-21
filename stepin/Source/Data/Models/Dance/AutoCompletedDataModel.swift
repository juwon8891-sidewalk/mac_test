import Foundation
import RxDataSources

class AutoCompletedDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: AutoCompetedData
}

struct AutoCompetedData: Codable {
    let dance: [CompletedData]
}

struct CompletedData: Codable {
    let title: String
}


//Data Section
struct AutoCompleteCollectionViewDataSection {
    var items: [CompletedData]
}

extension AutoCompleteCollectionViewDataSection: SectionModelType {
    typealias Item = CompletedData
    
    init(original: AutoCompleteCollectionViewDataSection, items: [CompletedData]) {
        self = original
        self.items = items
    }
}
