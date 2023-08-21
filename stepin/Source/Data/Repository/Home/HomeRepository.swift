import Foundation
import RxSwift

enum HomeApiType {
    case getShortform
}

class HomeRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    func getShortForm(page: Int) -> Observable<SuperShortFormCollectionViewDataSection> {
        var header: [String: String] = [:]
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            header = ["Content-Type": "application/json",
                      "accept": "application/json",
                      "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        } else {
            header = ["Content-Type": "application/json",
                      "accept": "application/json"]
        }
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/video/new/shortform?page=\(page)&limit=10",
                                                        headers: header)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(SuperShortformDataModel.self, from: result.get())
            let returnModel = SuperShortFormCollectionViewDataSection(items: json.data.newSuperShortform)
            return returnModel
        }
    }
}
