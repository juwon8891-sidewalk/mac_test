import Foundation
import RxSwift

class InboxRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    internal func getInboxData(page: Int) -> Observable<InboxTableviewDataSection>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/inbox?page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(InboxDataModel.self, from: result.get())
            let returnData = InboxTableviewDataSection(items: json.data.inbox)
            return returnData
        }
    }
    
    internal func patchInbox(inboxId: String) -> Observable<PatchInboxDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.patch(url: Constants.baseURL + "/inbox/\(inboxId)",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PatchInboxDataModel.self, from: result.get())
            return json
        }
    }
  
}
