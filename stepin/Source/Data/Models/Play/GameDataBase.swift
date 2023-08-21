import RealmSwift

class VideoInfoTable: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var dance_id: String = ""
    @Persisted var video_url: String = ""
    @Persisted var neonvideo_url: String = ""
    @Persisted var created_at: Date = Date()
    @Persisted var dance_name: String = ""
    @Persisted var artist_name: String = ""
    @Persisted var music_url: String = ""
    @Persisted var start_time: Float = 0
    @Persisted var end_time: Float = 0
    @Persisted var score: Float = 0
    @Persisted var sessionId: String = ""
    @Persisted var cover_url: String = ""
    @Persisted var isUploaded: Bool = false
    @Persisted var isLiked: Bool = false
    @Persisted var poseDataList = List<PoseTable>()
    @Persisted var scoreDataList = List<ScoreTable>()

    convenience init(dance_id: String,
                     video_url: String,
                     created_at: Date,
                     dance_name: String,
                     artist_name: String,
                     music_url: String,
                     start_time: Float ,
                     end_time: Float,
                     score: Float,
                     sessionId: String,
                     cover_url: String) {
        self.init()
        self.dance_id = dance_id
        self.video_url = video_url
        self.created_at = created_at
        self.dance_name = dance_name
        self.artist_name = artist_name
        self.music_url = music_url
        self.start_time = start_time
        self.end_time = end_time
        self.score = score
        self.sessionId = sessionId
        self.cover_url = cover_url
    }
}

public class PoseTable: Object {
    //여기 이 데이터 리스트변환만 잘하면 데이터 저장 가능
    @Persisted var data: List<Float32> = List<Float32>()
    @Persisted var time: Int = 0
    
    var dataArray: [Float32] {
        get {
            return data.map {$0}
        }
        set {
            data.removeAll()
            data.append(objectsIn: newValue)
        }
    }

    convenience init(data: [Float32],
                     time: Int) {
        self.init()
        self.dataArray = data
        self.time = time
    }
}


class ScoreTable: Object {
    @Persisted var score: Float = 0
    @Persisted var time: Int = 0

    convenience init(score: Float,
                     time: Int) {
        self.init()
        self.score = score
        self.time = time
    }
}
