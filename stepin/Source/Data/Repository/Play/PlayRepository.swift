import Foundation
import RxSwift

class PlayRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    func postCreatePlaySession(danceId: String, gameType: String) -> Observable<PlaySessionDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        let data = MakePlaySessionRequestBody(danceId: danceId,
                                              gameType: gameType)
        return self.defaultURLSessionNetworkService.post(data,
                                                         url: Constants.baseURL + "/play",
                                                         headers: authHeader)
        .map { result in
            return try self.defaultURLSessionNetworkService.modelDecoding(result, to: PlaySessionDataModel.self)
        }
    }
    
    internal func getGameTimeStampData(danceId: String) -> Observable<ScoreTimeStampDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.scoreBaseURL + "/api/score?dance_id=\(danceId)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(ScoreTimeStampDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func postGamePoseData(poseData: [PoseData], token: String, data: String?) -> Observable<GameScoreDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "Authorization": "Bearer \(token)"]
        
        let requestBody = PoseDataModel(poses: poseData, data: data)
        return self.defaultURLSessionNetworkService.post(requestBody,
                                                         url: Constants.scoreBaseURL + "/api/score/",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            print(try result.get().description)
            let json = try decoder.decode(GameScoreDataModel.self, from: result.get())
            return json
        }
    }

    internal func postPlayEndGame(poseData: [PoseData], token: String) -> Observable<Void> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "Authorization": "Bearer \(token)"]
        let requestBody = EndGamePoseDataModel(poses: poseData)
        print(requestBody )
        return self.defaultURLSessionNetworkService.post(requestBody,
                                                         url: Constants.scoreBaseURL + "/api/score/end",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            print(try result.get().description)
            let data = try result.get()
            print(data, result, "endDAta")
        }
        
        
    }
}
