import Foundation
import RxDataSources
import RealmSwift

struct HistoryVideoDataModel {
    let id: ObjectId
    let dance_id: String
    let video_url: String
    let neonVideo_url: String
    let created_at: Date
    let dance_name: String
    let artist_name: String
    let music_url: String
    let start_time: Float
    let end_time: Float
    let score: Float
    let sessionId: String
    let cover_url: String
    let isLiked: Bool
    let poseData: [PoseData]
    let scoreData: [Score]
}

struct HistoryColletionViewDataSection {
    var items: [HistoryVideoDataModel]
}

extension HistoryColletionViewDataSection: SectionModelType {
    typealias Item = HistoryVideoDataModel
    
    init(original: HistoryColletionViewDataSection, items: [HistoryVideoDataModel]) {
        self = original
        self.items = items
    }
}
