import Foundation
import RxSwift

final class GameRepository: GameRepositoryProtocol {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    func getGameTimeStampData(danceId: String) -> Observable<ScoreTimeStampDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.scoreBaseURL + "/api/score?dance_id=\(danceId)",
                                                        headers: authHeader)
        .map { result in
            return try self.defaultURLSessionNetworkService.modelDecoding(result, to: ScoreTimeStampDataModel.self)
        }
    }
    
    func postGamePoseData(poseData: [PoseData], token: String, data: String?) -> Observable<GameScoreDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "Authorization": "Bearer \(token)"]
        
        let data = PoseDataModel(poses: poseData,
                                 data: data)
        return self.defaultURLSessionNetworkService.post(data,
                                                         url: Constants.scoreBaseURL + "/api/score/",
                                                         headers: authHeader)
        .map { result in
            return try self.defaultURLSessionNetworkService.modelDecoding(result, to: GameScoreDataModel.self)
        }
    }
    
    func postPlayEndGame(poseData: [PoseData], token: String) -> Observable<Void> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "Authorization": "Bearer \(token)"]
        let data = EndGamePoseDataModel(poses: poseData)
        return self.defaultURLSessionNetworkService.post(data,
                                                         url: Constants.scoreBaseURL + "/api/score/end",
                                                         headers: authHeader)
        .map { _ in
            return ()
        }
    }
    
    
}
