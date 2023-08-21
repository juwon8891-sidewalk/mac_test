import Foundation
import RxSwift

class DanceRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    //play Hot Dance 조회*
    func getPlayHotDance(page: Int) -> Observable<PlayDanceDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/hot?page=\(page)&limit=9",
                                                        headers: authHeader)
        .map { result in
            return try self.defaultURLSessionNetworkService.modelDecoding(result, to: PlayDanceDataModel.self)
        }
    }
    
    //좋아요 한 Dance 조회*
    func getLikedDance(page: Int) -> Observable<PlayDanceDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/like?page=\(page)&limit=9",
                                                        headers: authHeader)
        .map { result in
            return try self.defaultURLSessionNetworkService.modelDecoding(result, to: PlayDanceDataModel.self)
        }
    }
    
    //Dance 좋아요*
    func patchLikeDane(danceId: String, state: Int) -> Observable<PatchLikeDanceDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.patch(url: Constants.baseURL + "/dance/like/\(danceId)?state=\(state)",
                                                          headers: authHeader)
        .map { result in
            return try self.defaultURLSessionNetworkService.modelDecoding(result, to: PatchLikeDanceDataModel.self)
        }
    }
    
    func getExpectedRank(danceId: String, score: Float) -> Observable<GetExpectedRankDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/\(danceId)/expected/rank?score=\(score)",
                                                        headers: authHeader)
        .map { result in
            return try self.defaultURLSessionNetworkService.modelDecoding(result, to: GetExpectedRankDataModel.self)
        }
    }
    
    internal func getDanceList(danceId: String, page: Int) -> Observable<RankingTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/\(danceId)/rank?page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(RankingDataModel.self, from: result.get())
            let returnModel = RankingTableviewDataSection(items: json.data.danceRankList)
            return returnModel
        }
    }
    
    internal func getHotDanceList(page: Int) -> Observable<SearchDanceListCollectionViewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/hot?page=\(page)",
                                                        headers: authHeader)
        .debug()
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(GetSearchDanceDataModel.self, from: result.get())
            let returnModel = SearchDanceListCollectionViewDataSection(items: json.data.dance)
            return returnModel
        }
    }
    
    //지금 데이터섹션에 종속당해서.. 우선은 중복으로 내비둡니다..
    //추후 수정을 해야할 부분입니다. 바로 위 함수와 동일한 함수입니다.
    //우선 limit 제한 없이 해둠. 무한스크롤 필요함
    internal func getPlayHotDanceList(page: Int) -> Observable<PlayDanceTableViewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/hot?page=\(page)&limit=150",
                                                        headers: authHeader)
        .debug()
        .map { result in
            print(result)
            let decoder = JSONDecoder()
            let json = try decoder.decode(PlayDanceDataModel.self, from: result.get())
            let returnModel = PlayDanceTableViewDataSection(items: json.data.dance)
            return returnModel
        }
    }
    
    internal func getLikeDanceList(page: Int) -> Observable<PlayDanceTableViewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/like?page=\(page)&limit=150",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PlayDanceDataModel.self, from: result.get())
            let returnModel = PlayDanceTableViewDataSection(items: json.data.dance)
            return returnModel
        }
    }
    
    internal func getDanceInfo(danceId: String) -> Observable<DanceInfoDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/\(danceId)/info",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(DanceInfoDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func getAutoCompleted(keyword: String) -> Observable<AutoCompleteCollectionViewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/autocompleted?keyword=\(keyword.replaceSpaceString(target: " ", withString: "%20"))",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(AutoCompletedDataModel.self, from: result.get())
            let returnModel = AutoCompleteCollectionViewDataSection(items: json.data.dance)
            return returnModel
        }
    }
    
    internal func getSearchDanceList(keyword: String, page: Int) -> Observable<SearchDanceListCollectionViewDataSection>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/search?keyword=\(keyword.replaceSpaceString(target: " ", withString: "%20"))&page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(GetSearchDanceDataModel.self, from: result.get())
            let returnModel = SearchDanceListCollectionViewDataSection(items: json.data.dance)
            return returnModel
        }
    }
    
    internal func patchLikeDance(danceId: String, state: Int) -> Observable<PatchLikeDanceDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.patch(url: Constants.baseURL + "/dance/like/\(danceId)?state=\(state)",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PatchLikeDanceDataModel.self, from: result.get())
            return json
        }
    }
    
    //내 예상등수 가져오기
    internal func getExtpectedRank(danceId: String, score: Float) -> Observable<GetExpectedRankDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/dance/\(danceId)/expected/rank?score=\(score)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(GetExpectedRankDataModel.self, from: result.get())
            return json
        }
    }
    
    
}
