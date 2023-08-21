import Foundation
import RealmSwift
import RxRelay
import RxSwift
import Sentry

class RealmRepository: RealmRepositoryType {
    static let realmRepository = RealmRepository()
    
    init() {}
    
    let localRealm = try? Realm()
    lazy var videoTasks: Results<VideoInfoTable>? = self.get()
    

    private var selectedData: [ObjectId] = []
    private var currentDate: Date = Date()
    
    let getHistoryCollectionViewData = PublishRelay<[HistoryColletionViewDataSection]>()
    
    private var collectionViewDataRelay = PublishRelay<[HistoryColletionViewDataSection]>()

    func get() -> Results<VideoInfoTable>? {
        guard let localRealm = localRealm else {return nil}

        return localRealm.objects(VideoInfoTable.self)
    }
    
    func createItem(item: VideoInfoTable) {
        guard let localRealm = localRealm else {return}
        do {
            try localRealm.write {
                localRealm.add(item)
            }
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    func deleteItem(item: Results<VideoInfoTable>) {
        guard let localRealm = localRealm else {return}
        try? localRealm.write{
            localRealm.delete(item)
        }
    }
    
    func getVideoItem(id: ObjectId) -> HistoryVideoDataModel? {
        guard let localRealm = localRealm else {return nil}
        do {
            if let read = localRealm.objects(VideoInfoTable.self).filter(NSPredicate(format: "id = %@", id)).first {
                let poseData: [PoseData] = read.poseDataList.map { PoseData.init(data: $0.dataArray,
                                                                                  time: $0.time) }
                let scoreData: [Score] = read.scoreDataList.map { Score(score: $0.score, time: $0.time)}
                return .init(id: read.id,
                             dance_id: read.dance_id,
                             video_url: read.video_url,
                             neonVideo_url: read.neonvideo_url,
                             created_at: read.created_at,
                             dance_name: read.dance_name,
                             artist_name: read.artist_name,
                             music_url: read.music_url,
                             start_time: read.start_time,
                             end_time: read.end_time,
                             score: read.score,
                             sessionId: read.sessionId,
                             cover_url: read.cover_url,
                             isLiked: read.isLiked,
                             poseData: poseData,
                             scoreData: scoreData)
            } else {
                return nil
            }
        }
    }
    
    func updateIsLikedState(id: ObjectId,
                            state: Bool) {
        guard let localRealm = localRealm else {return}
        do {
            if let update = localRealm.objects(VideoInfoTable.self).filter(NSPredicate(format: "id = %@", id)).first {
                try? localRealm.write {
                    update.isLiked = state
                }
            }
        }
    }
    
    func updateNeonVideoURL(id: ObjectId,
                            videoURL: String) {
        guard let localRealm = localRealm else {return}
        do {
            if let update = localRealm.objects(VideoInfoTable.self).filter(NSPredicate(format: "id = %@", id)).first {
                try? localRealm.write {
                    update.neonvideo_url = videoURL
                }
            }
        }
    }


}
