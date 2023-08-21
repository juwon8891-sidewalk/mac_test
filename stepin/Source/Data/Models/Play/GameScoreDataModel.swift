import Foundation

// MARK: - GameScoreDataModel
struct GameScoreDataModel: Codable {
    var score: Float
    var scores: [Score]
    var data: String
}

// MARK: - Score
struct Score: Codable {
    var score: Float
    var time: Int
}


//Post Reply Model
struct PoseDataModel: Codable {
    var poses: [PoseData]
    var data: String?
    
    init(poses: [PoseData], data: String? = nil) {
        if let scoreData = data {
            self.data = scoreData
        } else {
            self.data = nil
        }
        self.poses = poses
    }
}

struct PoseData: Codable {
    var data: [Float32]
    var time: Int
    
    init(data: [Float32], time: Int) {
        self.data = data
        self.time = time
    }
}


//endGameModel
struct EndGamePoseDataModel: Codable {
    var poses: [PoseData]
    
    init(poses: [PoseData]) {
        self.poses = poses
    }
}
