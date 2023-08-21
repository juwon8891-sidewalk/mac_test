import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

extension UserDefaults {
    // Token 관리
    @UserDefault(key: "googleAccessToken", defaultValue: "googleAccessToken")
    static var googleAccessToken: String
    
    @UserDefault(key: "facebookAccessToken", defaultValue: "facebookAccessToken")
    static var facebookAccessToken: String
    
    @UserDefault(key: "appleAccessToken", defaultValue: "appleAccessToken")
    static var appleAccessToken: String
    
    @UserDefault(key: "accessToken", defaultValue: "accessToken")
    static var accessToken: String
    
    @UserDefault(key: "refreshToken", defaultValue: "refreshToken")
    static var refreshToken: String
    
    @UserDefault(key: "getTokenTime", defaultValue: 0)
    static var getTokenTime: Int
    
    @UserDefault(key: "getRefreshTokenTime", defaultValue: 0)
    static var getRefreshTokenTime: Int
    
    // 회원가입 관리
    @UserDefault(key: "type", defaultValue: "type")
    static var type: String
    
    @UserDefault(key: "EMAIL_VERIFY", defaultValue: "EMAIL_VERIFY")
    static var emailVerifyType: String
    
    @UserDefault(key: "PASSWORD_RESET", defaultValue: "PASSWORD_RESET")
    static var passwordReset: String
    
    @UserDefault(key: "email", defaultValue: "email")
    static var email: String
    
    @UserDefault(key: "googleEmail", defaultValue: "googleEmail")
    static var googleEmail: String
    
    @UserDefault(key: "facebookEmail", defaultValue: "facebookEmail")
    static var facebookEmail: String
    
    @UserDefault(key: "appleEmail", defaultValue: "appleEmail")
    static var appleEmail: String
    
    @UserDefault(key: "password", defaultValue: "password")
    static var password: String
    
    @UserDefault(key: "birthDate", defaultValue: "birthDate")
    static var birthDate: String
    
    @UserDefault(key: "identifierName", defaultValue: "identifierName")
    static var identifierName: String
    
    
    // 비밀번호 찾기
    @UserDefault(key: "findPwdEmail", defaultValue: "findPwdEmail")
    static var findPwdEmail: String
    
    //유저 정보 저장
    @UserDefault(key: "userId", defaultValue: "userId")
    static var userId: String
    
    @UserDefault(key: "name", defaultValue: "name")
    static var name: String
    
    @UserDefault(key: "profileUrl", defaultValue: "profileUrl")
    static var profileUrl: String
    
    @UserDefault(key: "videoCount", defaultValue: "videoCount")
    static var videoCount: String
    
    @UserDefault(key: "videoName", defaultValue: "videoName")
    static var videoName: String
    
    @UserDefault(key: "nickName", defaultValue: "nickName")
    static var nickName: String
    
    
    // isLogin
    @UserDefault(key: "loginStatus", defaultValue: false)
    static var loginStatus: Bool
    
    @UserDefault(key: "currentEnergy", defaultValue: "currentEnergy")
    static var currentEnergy: String
    
    @UserDefault(key: "isSocialLogin", defaultValue: false)
    static var isSocialLogin: Bool
  
}




