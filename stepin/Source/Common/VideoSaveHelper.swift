import Foundation
import Realm
import RealmSwift
import Sentry

class VideoSaveHelper {
    static func makeVideoName() {
        let lastCount = UserDefaults.standard.integer(forKey: UserDefaultKey.videoCount) ?? 1
//        let videoName = UserDefaults.standard.setValue("/userDance\(lastCount).MP4", forKey: UserDefaultKey.videoName)
        let videoName = UserDefaults.standard.setValue("userDance\(lastCount).MP4", forKey: UserDefaultKey.videoName)
        UserDefaults.standard.setValue(lastCount + 1, forKey: UserDefaultKey.videoCount)
    }
    
    static func saveVideoToDataBase(videoPath: String,
                                    danceId: String,
                                    created_at: Date,
                                    artist_name: String,
                                    dance_name: String,
                                    music_url: String,
                                    start_time: Float,
                                    end_time: Float,
                                    score: Float,
                                    sessionId: String,
                                    cover_url: String,
                                    poseData: [PoseData],
                                    scoreData: [Score]) {
        var videoData = VideoInfoTable(dance_id: danceId,
                                       video_url: videoPath,
                                       created_at: created_at,
                                       dance_name: dance_name,
                                       artist_name: artist_name,
                                       music_url: music_url,
                                       start_time: start_time,
                                       end_time: end_time,
                                       score: score,
                                       sessionId: sessionId,
                                       cover_url: cover_url)
        
        do {
            let realm = try Realm()
                try realm.write {
                    videoData.poseDataList.removeAll()
                    poseData.forEach { pose in
                        videoData.poseDataList.append(pose.managedObject())
                    }
                    videoData.scoreDataList.removeAll()
                    scoreData.forEach { score in
                        videoData.scoreDataList.append(score.managedObject())
                    }
                    realm.add(videoData)
                    try realm.commitWrite()
                }
        } catch {
            SentrySDK.capture(error: error)
            print("Error creating video: \(error)")
        }
    }
    
}
