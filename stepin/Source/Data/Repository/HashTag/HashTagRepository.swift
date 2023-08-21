import UIKit
import RxSwift

class HashTagRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    //authHeader 불필요
    internal func getBoogieHashTag() -> Observable<BoogieTagCollectionViewDataSection>{
        var header: [String: String] = [:]
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            header = ["Content-Type": "application/json",
                      "accept": "application/json",
                      "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        } else {
            header = ["Content-Type": "application/json",
                      "accept": "application/json"]
        }
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/hashtag/boogie",
                                                        headers: header)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(BoogieHashTagDataModel.self, from: result.get())
            let returnModel = BoogieTagCollectionViewDataSection(items: json.data.boogieTag)
            return returnModel
        }
    }
    
    internal func getHashTagId(hashTag: String) -> Observable<GetHashTagDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        var tag = hashTag
        if tag != "" {
            tag.removeFirst()
        }
        var url: String = ""
        if let encodedHashTag = tag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            url = Constants.baseURL + "/hashtag?keyword=\(encodedHashTag)"
            print(url)
        }
        
        return self.defaultURLSessionNetworkService.get(url: url,
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(GetHashTagDataModel.self, from: result.get())
            return json
        }
    }
    
    
    internal func getTypeVideo(type: String,
                               targetId: String,
                               page: Int) -> Observable<HotCollectionViewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/type/\(targetId)?type=\(type)&page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(HotDataModel.self, from: result.get())
            let returnModel = HotCollectionViewDataSection(items: json.data.video)
            return returnModel
        }
    }
    
    internal func getSearchHashTag(page: Int,
                                   limit: Int = 20,
                                   keyword: String) -> Observable<SearchHashTagCollectionViewDataSection>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/hashtag/search?page=\(page)&limit=\(limit)&keyword=\(keyword.replaceSpaceString(target: " ", withString: "%20"))",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(SearchHashTagDataModel.self, from: result.get())
            let returnModel = SearchHashTagCollectionViewDataSection(items: json.data.hashtag)
            return returnModel
        }
    }
}
