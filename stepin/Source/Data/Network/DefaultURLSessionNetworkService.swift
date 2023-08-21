import Foundation
import RxSwift
import Sentry

final class DefaultURLSessionNetworkService: URLSessionNetworkService {
    private let tokenUtils = TokenUtils()
    private enum HTTPMethod {
        static let get = "GET"
        static let post = "POST"
        static let patch = "PATCH"
        static let delete = "DELETE"
        static let put = "PUT"
    }
    
    func postSocial<T: Codable>(
        _ data: T,
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.requestSocial(with: data, url: urlString, headers: headers, method: HTTPMethod.post)
    }
    
        
    func post<T: Codable>(
        _ data: T,
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(with: data, url: urlString, headers: headers, method: HTTPMethod.post)
    }
    
    
    func post(
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(url: urlString, headers: headers, method: HTTPMethod.post)
    }
    
    func put<T: Codable>(
        _ data: T,
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(with: data, url: urlString, headers: headers, method: HTTPMethod.put)
    }
    
    func patch<T: Codable>(
        _ data: T,
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(with: data, url: urlString, headers: headers, method: HTTPMethod.patch)
    }
    
    func patch(
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(url: urlString, headers: headers, method: HTTPMethod.patch)
    }
    
    func delete(
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(url: urlString, headers: headers, method: HTTPMethod.delete)
    }
    
    func get(
        url urlString: String,
        headers: [String: String]?
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(url: urlString, headers: headers, method: HTTPMethod.get)
    }
    
    
    private func request(
        url urlString: String,
        headers: [String: String]? = nil,
        method: String
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        guard let url = URL(string: urlString) else {
            return Observable.error(URLSessionNetworkServiceError.invalidURLError)
        }

        return Observable<Result<Data, URLSessionNetworkServiceError>>.create { emitter in
            let request = self.createHTTPRequest(of: url, with: headers, httpMethod: method)
            let task = URLSession.shared.dataTask(with: request) { data, reponse, error in
                guard let httpResponse = reponse as? HTTPURLResponse else {
                    emitter.onError(URLSessionNetworkServiceError.unknownError)
                    return
                }
                /**
                 get Access Token and Refresh Token
                 In get Request
                 */
                
                print(httpResponse, url)
                UserDefaults.standard.set(httpResponse.statusCode, forKey: "statusCode")
                
                //갱신 실패시
                if httpResponse.statusCode == 400 {
                    
                }
                
                if error != nil {
                    emitter.onError(self.configureHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    emitter.onError(self.configureHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    emitter.onNext(.failure(.emptyDataError))
                    return
                }
                
                if let accessToken = httpResponse.headers["accesstoken"] {
                    if(self.tokenUtils.read(account: UserDefaultKey.accessToken) != accessToken && !accessToken.isEmpty) {
                        self.tokenUtils.setTokenCreateTime()
                        self.tokenUtils.create(account: UserDefaultKey.accessToken, value: accessToken)
                    }
                    print("accessToken: \(accessToken)")
                    
                }
                if let refreshToken = httpResponse.headers["refreshtoken"] {
                    if(self.tokenUtils.read(account: UserDefaultKey.refreshToken) != refreshToken && !refreshToken.isEmpty) {
                        self.tokenUtils.setRefreshTokenCreateTime()
                        self.tokenUtils.create(account: UserDefaultKey.refreshToken, value: refreshToken)
                    }
                    print("refreshToken: \(refreshToken)")
                }
                
                emitter.onNext(.success(data))
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func request<T: Codable>(
        with bodyData: T,
        url urlString: String,
        headers: [String: String]? = nil,
        method: String
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        guard let url = URL(string: urlString),
              let httpBody = self.createPostPayload(from: bodyData) else {
                  return Observable.error(URLSessionNetworkServiceError.emptyDataError)
              }
        
        
        return Observable<Result<Data, URLSessionNetworkServiceError>>.create { emitter in
            let request = self.createHTTPRequest(of: url, with: headers, httpMethod: method, with: httpBody)
            let task = URLSession.shared.dataTask(with: request) { data, reponse, error in
                
                guard let httpResponse = reponse as? HTTPURLResponse else {
                    emitter.onError(URLSessionNetworkServiceError.unknownError)
                    return
                }
                /**
                 get Access Token and Refresh Token
                 In Post Request
                 */
                print(httpResponse.statusCode, url)
                
                if error != nil {
                    emitter.onError(self.configureHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    emitter.onError(self.configureHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    emitter.onNext(.failure(.emptyDataError))
                    return
                }
                
                if let accessToken = httpResponse.headers["accesstoken"] {
                    if(self.tokenUtils.read(account: UserDefaultKey.accessToken) != accessToken && !accessToken.isEmpty) {
                        self.tokenUtils.setTokenCreateTime()
                        self.tokenUtils.create(account: UserDefaultKey.accessToken, value: accessToken)
                    }
                    print("accessToken: \(accessToken)")
                    
                }
                if let refreshToken = httpResponse.headers["refreshtoken"] {
                    if(self.tokenUtils.read(account: UserDefaultKey.refreshToken) != refreshToken && !refreshToken.isEmpty) {
                        self.tokenUtils.setRefreshTokenCreateTime()
                        self.tokenUtils.create(account: UserDefaultKey.refreshToken, value: refreshToken)
                    }
                    print("refreshToken: \(refreshToken)")
                }
                
                emitter.onNext(.success(data))
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    private func requestSocial<T: Codable>(
        with bodyData: T,
        url urlString: String,
        headers: [String: String]? = nil,
        method: String
    ) -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        guard let url = URL(string: urlString),
              let httpBody = self.createPostPayload(from: bodyData) else {
                  return Observable.error(URLSessionNetworkServiceError.emptyDataError)
              }
        return Observable<Result<Data, URLSessionNetworkServiceError>>.create { emitter in
            let request = self.createHTTPRequest(of: url, with: headers, httpMethod: method, with: httpBody)
            let task = URLSession.shared.dataTask(with: request) { data, reponse, error in
                
                guard let httpResponse = reponse as? HTTPURLResponse else {
                    emitter.onError(URLSessionNetworkServiceError.unknownError)
                    return
                }
                
                print(httpResponse.statusCode, url)
                
                if error != nil {
                    emitter.onError(self.configureHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                /**
                 get Access Token and Refresh Token
                 In Post Request
                 */
                if let accessToken = httpResponse.headers["accesstoken"] {
                    if(self.tokenUtils.read(account: UserDefaultKey.accessToken) != accessToken && !accessToken.isEmpty) {
                        self.tokenUtils.setTokenCreateTime()
                        self.tokenUtils.create(account: UserDefaultKey.accessToken, value: accessToken)
                    }
                    print("accessToken: \(accessToken)")
                    
                }
                if let refreshToken = httpResponse.headers["refreshtoken"] {
                    if(self.tokenUtils.read(account: UserDefaultKey.refreshToken) != refreshToken && !refreshToken.isEmpty) {
                        self.tokenUtils.setRefreshTokenCreateTime()
                        self.tokenUtils.create(account: UserDefaultKey.refreshToken, value: refreshToken)
                    }
                    print("refreshToken: \(refreshToken)")
                }
                
                guard 200...500 ~= httpResponse.statusCode else {
                    emitter.onError(self.configureHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                
                guard let data = data else {
                    emitter.onNext(.failure(.emptyDataError))
                    return
                }
                emitter.onNext(.success(data))
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    func generateDataInRange(_ data: Data, range: Range<Int>) -> Observable<Data> {
        return Observable.create { observer in
            let subdata = data.subdata(in: range)
            observer.onNext(subdata)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    private func createPostPayload<T: Codable>(from requestBody: T) -> Data? {
        if let data = requestBody as? Data {
            return data
        }
        return try? JSONEncoder().encode(requestBody)
    }
    
    private func configureHTTPError(errorCode: Int) -> Error {
        return URLSessionNetworkServiceError(rawValue: errorCode)
        ?? URLSessionNetworkServiceError.unknownError
    }

    private func createHTTPRequest(
        of url: URL,
        with headers: [String: String]?,
        httpMethod: String,
        with body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        headers?.forEach({ header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        })
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    func modelDecoding<T: Decodable>(_ result: Result<Data, URLSessionNetworkServiceError>, to type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            let json = try decoder.decode(T.self, from: result.get())
            return json
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }
  
    }
}
