import Foundation
import RxRelay
import RxSwift

final class UserRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    private let defaultHeader = ["Content-Type": "application/json",
                                 "accept": "application/json"]
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    //유저 프로필 데이터 불러오기
    func getUserProfile(type: String, data: String) -> Observable<MyPageModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/mypage?type=\(type)&data=\(data)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(MyPageModel.self, from: result.get())
            return json
        }
        //내 프로필 정보로 만든 동영상 불러오기 해서 items에 삽입
    }
    
    //팔로잉 리스트 불러오기
    func getUserFollowingList(userId: String, page: Int) -> Observable<FollowingTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/following/\(userId)?page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(FollowingModel.self, from: result.get())
            let returnModel = FollowingTableviewDataSection(items: json.data.followingList)
            return returnModel

        }
    }
    
    //팔로잉 리스트 불러오기
    func getUserFollowerList(userId: String, page: Int) -> Observable<FollowerTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/follower/\(userId)?page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(FollowerModel.self, from: result.get())
            let returnModel = FollowerTableviewDataSection(items: json.data.followerList)
            return returnModel

        }
    }
   
    //팔로워 유저 검색
    func getSearchFollowerUserList(userId: String, stepinId: String, page: Int) -> Observable<FollowerTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/follower/\(userId)?identifierName=\(stepinId)&page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(FollowerModel.self, from: result.get())
            let returnModel = FollowerTableviewDataSection(items: json.data.followerList)
            return returnModel
        }
    }

    //팔로잉 유저 검색
    func getSearchFollowingUserList(userId: String, stepinId: String, page: Int) -> Observable<FollowingTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/following/\(userId)?identifierName=\(stepinId)&page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(FollowingModel.self, from: result.get())
            let returnModel = FollowingTableviewDataSection(items: json.data.followingList)
            return returnModel
        }
    }
    
    //나 팔로우 한놈 삭제 하기
    func deleteMyFollower(followId: String) -> Observable<DeleteFollowerModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.delete(url: Constants.baseURL + "/user/follower/\(followId)",
                                                           headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(DeleteFollowerModel.self, from: result.get())
            return json
        }
    }
    
    //팔로우 하기
    func patchFollowUser(userId: String, state: Int) -> Observable<PatchFollowModel>{
        //state 1 == folowing
        //state -1 == unfollow
        let authHeader: [String: String] = ["accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        print(userId, state)
        return self.defaultURLSessionNetworkService.patch(url: Constants.baseURL + "/user/following/\(userId)?state=\(state)",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PatchFollowModel.self, from: result.get())
            return json
        }
    }
    
    //BlockList
    func getBlockUserList(page: Int) -> Observable<BlockTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/blocking?page=\(page)",
                                                        headers: authHeader)
        
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(BlockUserModel.self, from: result.get())
            print(json)
            let returnModel = BlockTableviewDataSection(items: json.data.blockList)
            return returnModel
        }
    }
    
    func postUserBlock(state: Int, userId: String) -> Observable<PostBlockUserModel>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.post(url: Constants.baseURL + "/user/blocking/\(userId)?state=\(state)",
                                                         headers: authHeader)
        
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PostBlockUserModel.self, from: result.get())
            return json
        }
    }
    
    func patchUserInfo(stepinId: String,
                       name: String,
                       videoId: String?) -> Observable<PatchModifyProfileModel>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        let dto = ModifyProfile(identiferName: stepinId,
                                name: name,
                                videoId: videoId)
        return self.defaultURLSessionNetworkService.patch(dto,
                                                          url: Constants.baseURL + "/user",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PatchModifyProfileModel.self, from: result.get())
            return json
        }
    }
    
    func putImage(url: String, headerValue: [String], image: UIImage) -> Observable<Void> {
        let imageHeader: [String: String] = ["Content-Type": headerValue[0],
                                             "x-goog-meta-userId": headerValue[1],
                                             "x-goog-meta-type": headerValue[2]]
        
        let data = image.pngData() ?? Data(count: 1)
        //이미지 바디 넣어줌
            return self.defaultURLSessionNetworkService.put(data,
                                                     url: url,
                                                     headers: imageHeader)
            .map { result in
//                let decoder = JSONDecoder()
//                let json = try decoder.decode(PatchModifyProfileModel.self, from: result.get())
                return ()
            }
    }
    
    internal func getSearchUserData(name: String, page: Int) -> Observable<SearchUserCollectionViewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        print(Constants.baseURL + "/user?name=\(name.replaceSpaceString(target: " ", withString: "%20"))&page=\(page)")
        print(Constants.baseURL + "/user?name=\(name)&page=\(page)")

        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user?name=\(name.replaceSpaceString(target: " ", withString: "%20"))&page=\(page)",
                                                         headers: authHeader)
        
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(SearchUserDataModel.self, from: result.get())
            let returnModel = SearchUserCollectionViewDataSection(items: json.data.userList)
            return returnModel
        }
    }
    
    internal func getUserStamina() -> Observable<StaminaDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]

        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/stamina",
                                                         headers: authHeader)
        
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(StaminaDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func deleteWidthdrawalUser() -> Observable<WithdrawlDataModel>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.delete(url: Constants.baseURL + "/user",
                                                           headers: authHeader)
        
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(WithdrawlDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func getUserDynamicLink(userId: String) -> Observable<DynamicLinkDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/dynamiclink/\(userId)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(DynamicLinkDataModel.self, from: result.get())
            return json
        }
    }
    
    internal func postReportUser(userId: String,
                                 content: String) -> Observable<ReportUserDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        let data = PostReportUserModel(userId: userId,
                                       content: content)
        return self.defaultURLSessionNetworkService.post(data,
                                                         url: Constants.baseURL + "/user/reporting",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(ReportUserDataModel.self, from: result.get())
            return json
        }
    }
    
    func patchBoostUser(userId: String) -> Observable<PatchUserBoostDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.patch(url: Constants.baseURL + "/user/boost/\(userId)",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PatchUserBoostDataModel.self, from: result.get())
            return json
        }
    }
    
    func getBoostIsPossible() -> Observable<GetCheckBoostDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/user/check/boost",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(GetCheckBoostDataModel.self, from: result.get())
            return json
        }
    }
    
}
