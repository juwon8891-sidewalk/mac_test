import Foundation

enum UserDefaultKey {
    //tokken 관리
    static let accessToken: String = "accessToken"
    static let refreshToken: String = "refreshToken"
    
    //회원가입 관련
    static let emailVerifyType: String = "EMAIL_VERIFY"
    static let passwordReset: String = "PASSWORD_RESET"
    static let email: String = "email"
    static let password: String = "password"
    static let birthDate: String = "birthDate"
    static let identifierName: String = "identifierName"
    
    //비밀번호 찾기
    static let findPwdEmail: String = "findPwdEmail"

    //유저 정보 저장
    static let userId: String = "userId"
    static let name: String = "name"
    static let profileUrl = "profileUrl"
    
    
    static let videoCount: String = "videoCount"
    static let videoName: String = "videoName"
    
    //isLogin
    static let LoginStatus: String = "LoginStatus"
    
    static let currentEnergy: String = "currentEnergy"
}
