import Foundation
import RxDataSources

struct BoogieHashTagDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: BoogieHashTagData
}


struct BoogieHashTagData: Codable {
    let boogieTag: [BoogieTag]
}


struct BoogieTag: Codable {
    let artistID, artist: String
    let childBoogieTag: [ChildBoogieTag]

    enum CodingKeys: String, CodingKey {
        case artistID = "artist_id"
        case artist, childBoogieTag
    }
}


struct ChildBoogieTag: Codable {
    let musicID, music: String

    enum CodingKeys: String, CodingKey {
        case musicID = "music_id"
        case music
    }
}

//상단 부기 태그
struct BoogieTagCollectionViewDataSection {
    var items: [BoogieTag]
}

extension BoogieTagCollectionViewDataSection: SectionModelType {
    typealias Item = BoogieTag
    
    init(original: BoogieTagCollectionViewDataSection, items: [BoogieTag]) {
        self = original
        self.items = items
    }
}


//하단 부기 태그
struct BoogieBottomTagCollectionViewDataSection {
    var items: [ChildBoogieTag]
}

extension BoogieBottomTagCollectionViewDataSection: SectionModelType {
    typealias Item = ChildBoogieTag
    
    init(original: BoogieBottomTagCollectionViewDataSection, items: [ChildBoogieTag]) {
        self = original
        self.items = items
    }
}
