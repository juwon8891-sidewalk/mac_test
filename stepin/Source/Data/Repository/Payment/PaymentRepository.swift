import Foundation
import RxSwift
import Sentry

class PaymentRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }

    func postReceiptsToVerification(receipt: String) -> Observable<PaymentDataModel>{
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        let requestBody = receiptsRequestBody(receipt: receipt)
        return self.defaultURLSessionNetworkService.post(requestBody,
                                                         url: Constants.paymentURL + "/payment/consumable/ios",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PaymentDataModel.self, from: result.get())
            return json
        }
    }
    
//    func getProductIp(ip: String) -> Observable<ProductIPModel> {
//        let header: [String: String] = ["accept": "*/*",
//                                        "x-forwarded-for": "\(ip)"]
//        return self.defaultURLSessionNetworkService.get(url: Constants.paymentURL + "product/policy/ip", headers: header)
//        .map { result in
//            let decoder = JSONDecoder()
//            let json = try decoder.decode(ProductIPModel.self, from: result.get())
//            return json
//        }
//    }
    // 추후 수정 
    func getPaymentServerToProductList(ip: String, completion: @escaping (ProductIPModel) -> Void) {
        var request = URLRequest(url: URL(string: Constants.paymentURL + "/product/policy/ip")!, timeoutInterval: Double.infinity)
//        request.addValue("*/*", forHTTPHeaderField: "accept")
//        request.addValue("\(ip)", forHTTPHeaderField: "x-forwarded-for")
        request.addValue("Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))", forHTTPHeaderField: "accesstoken")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("error")
                return
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return
            }

            if let accessToken = httpResponse.headers["accesstoken"] {
                if(self.tokenUtil.read(account: UserDefaultKey.accessToken) != accessToken && !accessToken.isEmpty) {
                    self.tokenUtil.setTokenCreateTime()
                    self.tokenUtil.create(account: UserDefaultKey.accessToken, value: accessToken)
                }
                print("accessToken: \(accessToken)")

            }
            if let refreshToken = httpResponse.headers["refreshtoken"] {
                if(self.tokenUtil.read(account: UserDefaultKey.refreshToken) != refreshToken && !refreshToken.isEmpty) {
                    self.tokenUtil.setRefreshTokenCreateTime()
                    self.tokenUtil.create(account: UserDefaultKey.refreshToken, value: refreshToken)
                }
                print("refreshToken: \(refreshToken)")
            }
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ProductIPModel.self, from: data)
                completion(model)
            } catch {
                SentrySDK.capture(error: error)
//                print("디코딩 에러: \(error)")
            }
            
        }
        task.resume()
    }
    
    
    
}
