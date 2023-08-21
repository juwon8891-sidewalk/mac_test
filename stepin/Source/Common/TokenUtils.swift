import Security
import Foundation
import Alamofire

class TokenUtils {
    
    private let serviceIdentifier: String = Bundle.main.bundleIdentifier ?? "com.sidewalk.stepin"
    
    // Create
    func create(account: String, value: String) {
        
        // 1. query작성
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService: serviceIdentifier,
            kSecAttrAccount: account,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
        ]
        // allowLossyConversion은 인코딩 과정에서 손실이 되는 것을 허용할 것인지 설정
        
        // 2. Delete
        // Key Chain은 Key값에 중복이 생기면 저장할 수 없기때문에 먼저 Delete
        SecItemDelete(keyChainQuery)
        
        // 3. Create
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "failed to saving Token")
    }
    
    // Read
    func read(account: String) -> String? {
        let KeyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceIdentifier,
            kSecAttrAccount: account,
            kSecReturnData: true, // CFData타입으로 불러오라는 의미
            kSecMatchLimit: kSecMatchLimitOne // 중복되는 경우 하나의 값만 가져오라는 의미
        ]
        // CFData 타입 -> AnyObject로 받고, Data로 타입변환해서 사용하면됨
        
        // Read
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(KeyChainQuery, &dataTypeRef)
        
        // Read 성공 및 실패한 경우
        if(status == errSecSuccess) {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8)
            return value
        } else {
            print("failed to loading, status code = \(status)")
            return nil
        }
    }
    // Delete
    func delete(_ account: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceIdentifier,
            kSecAttrAccount: account
        ]

        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "failed to delete the value, status code = \(status)")
    }

    // HTTPHeaders 구성
    func getAuthorizationHeader() -> HTTPHeaders? {
        if let accessToken = self.read(account: "accessToken") {
            return ["accesstoken" : "Bearer \(accessToken)" ,
                    "Content-Type": "application/json"] as HTTPHeaders
        } else {
            return nil
        }
    }
    func getRefreshAuthorizationHeader() -> HTTPHeaders? {
        guard let accessToken = self.read(account: "accessToken") else {return nil}
        guard let refreshToken = self.read(account: "refreshToken") else {return nil}
        
        return ["accesstoken": "Bearer \(accessToken)" ,
                "refreshtoken": "Bearer \(refreshToken)",
                "Content-Type": "application/json"] as HTTPHeaders
    }
    
    //토큰 업데이트 관련 timeStamp
    func didTokenUpdate() -> Bool{
        let tokenTime = UserDefaults.standard.integer(forKey: "getTokenTime")
        let refreshTokenTime = UserDefaults.standard.integer(forKey: "getRefreshTokenTime")
        
        print(self.read(account: "accessToken"))
        //일반 토큰 업데이트 한지 10분 이상 지났을 때
        if Date().convertTimeStampToMinuite(date: tokenTime) >= 25 {
            return true
        }
        //리프레시 토큰을 업데이트 한 지 14일 이상 지났을 때
        else if Date().convertTimeStampToMinuite(date: refreshTokenTime) >= 20160 {
            return true
        }
        //아닐경우엔 api request의 수를 줄이기 위해 토큰 업데이트를 진행하지 않음
        else {
            return false
        }
    }
    
    //토큰 생성/업데이트시, userDefaults에 해당 시간을 기록해줌
    func setTokenCreateTime() {
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: "getTokenTime")
    }
    //리프레시토큰 생성/업데이트시, userDefaults에 해당 시간을 기록해줌
    func setRefreshTokenCreateTime() {
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: "getRefreshTokenTime")
    }
    //token이 존재하는지 확인
    func isTokenExists(account: String) -> Bool {
        if read(account: account) == nil || read(account: account) == ""{
            return false
        } else {
            return true
        }
    }
}
