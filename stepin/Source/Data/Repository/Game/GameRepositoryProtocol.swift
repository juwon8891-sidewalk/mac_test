import Foundation
import RxSwift

protocol GameRepositoryProtocol {
    func getGameTimeStampData(danceId: String) -> Observable<ScoreTimeStampDataModel>
    func postGamePoseData(poseData: [PoseData], token: String, data: String?) -> Observable<GameScoreDataModel>
    func postPlayEndGame(poseData: [PoseData], token: String) -> Observable<Void>
}
