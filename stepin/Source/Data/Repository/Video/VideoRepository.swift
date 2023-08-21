import Foundation
import RxSwift
import Sentry

enum GetTypeVideoType {
    static let artist = "ARTIST"
    static let dance = "DANCE"
    static let music = "MUSIC"
    static let hashtag = "HASHTAG"
}

class VideoRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    internal func getSearchHotVideo(keyword: String,
                                    page: Int,
                                    limit: Int = 18) -> Observable<SearchHotVideoCollectionViewDataSection>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/search?keyword=\(keyword.replaceSpaceString(target: " ", withString: "%20"))&page=\(page)&limit=\(limit)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(SearchHotVideoDataModel.self, from: result.get())
            let returnModel = SearchHotVideoCollectionViewDataSection(items: json.data.video)
            return returnModel
        }
    }
    
    //user의 비디오 조회
    internal func getUserVideo(type: String, userId: String, page: Int) -> Observable<MyPageVideoDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/user?type=\(type)&value=\(userId)&page=\(page)&limit=9",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(MyPageVideoDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func getTypeVideo(type: String,
                               targetId: String,
                               page: Int) -> Observable<HotCollectionViewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/type/\(targetId.replaceSpaceString(target: " ", withString: "%20"))?type=\(type)&page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(HotDataModel.self, from: result.get())
            let returnModel = HotCollectionViewDataSection(items: json.data.video)
            return returnModel
        }
    }
    
    //auth 필요없음
    internal func getBoogieTypeVideo(type: String,
                               targetId: String,
                               page: Int) -> Observable<BoogieVideoCollectionViewDataSection> {
        var header: [String: String] = [:]
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            header = ["Content-Type": "application/json",
                      "accept": "application/json",
                      "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        } else {
            header = ["Content-Type": "application/json",
                      "accept": "application/json"]
        }
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/type/\(targetId)?type=\(type)&page=\(page)",
                                                        headers: header)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(BoogieVideoDataModel.self, from: result.get())
            let returnModel = BoogieVideoCollectionViewDataSection(items: json.data.video)
            return returnModel
        }
    }
    
    //auth 필요없음
    internal func getNowVideo(page: Int) -> Observable<BoogieVideoCollectionViewDataSection> {
        var header: [String: String] = [:]
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            header = ["Content-Type": "application/json",
                      "accept": "application/json",
                      "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        } else {
            header = ["Content-Type": "application/json",
                      "accept": "application/json"]
        }
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/now?page=\(page)",
                                                        headers: header)
        .map {
            result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(NowVideoDataModel.self, from: result.get())
            let returnModel = BoogieVideoCollectionViewDataSection(items: json.data.video)
            return returnModel
        }
    }
    
    internal func patchLikeVideo(videoId: String, state: Int) -> Observable<LikeVideoDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.patch(url: Constants.baseURL + "/video/like/\(videoId)?state=\(state)",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(LikeVideoDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func postVideo(danceId: String,
                            score: String,
                            content: String,
                            hashTags: [String],
                            allowComment: Bool,
                            openScore: Bool,
                            gameType: String,
                            sessionId: String) -> Observable<UploadVideoDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        let data = PostVideoRequestBody(danceId: danceId,
                                        score: score,
                                        content: content,
                                        hashtag: hashTags,
                                        allowComment: allowComment,
                                        openScore: openScore,
                                        gameType: gameType,
                                        sessionId: sessionId)
        print(data)
        return self.defaultURLSessionNetworkService.post(data,
                                                         url: Constants.baseURL + "/video",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(UploadVideoDataModel.self, from: result.get())
            return json
        }
    }
    
    func patchUploadVideoFile(url: String, headerValue: [String], videoPath: String) -> Observable<Void> {
        let imageHeader: [String: String] = ["Content-Type": headerValue[0],
                                             "x-goog-meta-videoId": headerValue[1],
                                             "x-goog-meta-type": headerValue[2]]
        var videoData: Data?
        let videoUrl = URL(filePath: videoPath)
        do {
            videoData = try Data(contentsOf: videoUrl, options: .alwaysMapped)
        } catch {
            SentrySDK.capture(error: error)
            videoData = nil
        }
        
        //이미지 바디 넣어줌
        return self.defaultURLSessionNetworkService.put(videoData ?? Data(),
                                                        url: url,
                                                        headers: imageHeader)
            .map { result in
                return ()
            }
    }
    
    func patchUploadVideoThumbnailFile(url: String, headerValue: [String], thumbnail: UIImage) -> Observable<Void> {
        let imageHeader: [String: String] = ["Content-Type": headerValue[0],
                                             "x-goog-meta-videoId": headerValue[1],
                                             "x-goog-meta-type": headerValue[2]]
        let data = thumbnail.pngData() ?? Data(count: 1)
        //이미지 바디 넣어줌
            return self.defaultURLSessionNetworkService.put(data,
                                                     url: url,
                                                     headers: imageHeader)
            .map { result in
                return ()
            }
    }
    
    func getVideoInfo(videoId: String) -> Observable<NormalVideoCollectionViewDataSection> {
        let header: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/\(videoId)/info",
                                                        headers: header)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(GetVideoInfoDataModel.self, from: result.get())
            let returnModel = NormalVideoCollectionViewDataSection(items: [json.data.video])
            return returnModel
        }
    }
    
    internal func getVideoDynamicLink(videoId: String) -> Observable<DynamicLinkDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/dynamiclink/\(videoId)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(DynamicLinkDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func deleteVideo(videoId: String) -> Observable<Void> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.delete(url: Constants.baseURL + "/video/\(videoId)",
                                                           headers: authHeader)
        .map { result in
            return ()
        }
    }
    
    internal func patchModifyVideo(videoId: String,
                                   content: String,
                                   hashTag: [String],
                                   allowComment: Bool,
                                   openScore: Bool) -> Observable<PatchModifyVideoData> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        let requestBody = ModifyVideoDataModel(content: content,
                                               hashTag: hashTag,
                                               allowComment: allowComment,
                                               openScore: openScore)
        return self.defaultURLSessionNetworkService.patch(requestBody,
                                                          url: Constants.baseURL + "/video/\(videoId)",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PatchModifyVideoData.self, from: result.get())
            return json
        }
    }
}
