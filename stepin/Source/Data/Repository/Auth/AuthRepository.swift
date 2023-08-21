import Foundation
import RxRelay
import RxSwift
import Alamofire

final class AuthRepository {
    
    weak var coordinator: LoginCoordinator? // 추가
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    private let defaultHeader = ["Content-Type": "application/json",
                                 "accept": "application/json"]
    private let tokenUtils = TokenUtils()
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    //중복 확인
    func postCheckDuplicateAuth(value: String,
                                property: String) -> Observable<AuthCheckDuplicateModel> {
        let dto = AuthCheckDuplicateDTO(value: value)
        return self.defaultURLSessionNetworkService.post(dto,
                                                         url: Constants.baseURL + "/auth/\(property)/verification",
                                                         headers: defaultHeader
        )
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(AuthCheckDuplicateModel.self, from: result.get())
            return json
        }
    }
    
    //이메일 인증
    func postEmailAuthentication(dto: EmailAuthenticationDTO) -> Observable<VerifyEmailModel> {
        return self.defaultURLSessionNetworkService.post(dto,
                                                  url: Constants.baseURL + "/auth/email",
                                                  headers: defaultHeader
        )
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(VerifyEmailModel.self, from: result.get())
            return json
        }
    }
    
    //이메일 인증이 되었는지 안되었는지 확인
    func getEmailAuthenticationConfirm(type: EmailAuthnticatyionType) -> Observable<CheckVerifyEmailModel> {
        var token: String = ""
        if type == .normal {
            token = tokenUtils.read(account: "emailVerify") ?? ""
        } else {
            token = tokenUtils.read(account: "findEmailVerify") ?? ""
        }
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/auth/email/check/\(token)",
                                                 headers: defaultHeader
        )
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(CheckVerifyEmailModel.self, from: result.get())
            return json
        }
    }
    
    //이메일 회원가입 구현
    func postEmailSignUp() -> Observable<SignUpModel> {
        let dto = EmailSignUpInformationDTO(type: "EMAIL",
                                            email: UserDefaults.standard.string(forKey: UserDefaultKey.email) ?? "",
                                            password: tokenUtils.read(account: UserDefaultKey.password) ?? "",
                                            birthDate: UserDefaults.standard.string(forKey: UserDefaultKey.birthDate) ?? "",
                                            identifierName: UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) ?? "")
        print(dto)
        return self.defaultURLSessionNetworkService.post(dto,
                                                         url: Constants.baseURL + "/auth/signup",
                                                         headers: defaultHeader
        )
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(SignUpModel.self, from: result.get())
            return json
        }
    }
    
    //이메일 로그인 구현
    func postEmailSignIn(email: String, password: String) -> Observable<EmailSignInModel> {
        let dto = EmailLoginDTO(type: AuthLoginInfo.emailType,
                                email: email,
                                password: password)
        print(dto)
        return self.defaultURLSessionNetworkService.post(dto,
                                                         url: Constants.baseURL + "/auth/signin",
                                                         headers: defaultHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(EmailSignInModel.self, from: result.get())
            return json
        }
    }
    
    // 소셜 회원가입 구현
    func postSocialSignUp(LoginType: String, accessToken: String) -> Observable<SignUpModel> {
        let dto = SocialSignUpInformationDTO(type: LoginType,
                                             accessToken: accessToken,
                                            birthDate: UserDefaults.standard.string(forKey: UserDefaultKey.birthDate) ?? "",
                                            identifierName: UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) ?? "")
        print(dto)
        return self.defaultURLSessionNetworkService.postSocial(dto,
                                                         url: Constants.baseURL + "/auth/signup",
                                                         headers: defaultHeader
        )
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(SignUpModel.self, from: result.get())
            return json
        }
    }

    // 소셜 로그인 구현
    func postSocialSignIn(type:String, accessToken: String) -> Observable<EmailSignInModel> {
        let dto = SocialLoginDTO(type: type,
                                accessToken: accessToken)
        print(dto)
        return self.defaultURLSessionNetworkService.postSocial(dto,
                                                         url: Constants.baseURL + "/auth/signin",
                                                         headers: defaultHeader)
        
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(EmailSignInModel.self, from: result.get())
            return json
        }
    }
    
    //비밀번호 재설정
    func postResetPassword() -> Observable<ResetPasswordModel> {
        return self.defaultURLSessionNetworkService.post(ResetPasswordDTO(),
                                                         url: Constants.baseURL + "/auth/reset/password",
                                                         headers: defaultHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(ResetPasswordModel.self, from: result.get())
            return json
        }
    }
    
    //토큰 갱신
    func postRefreshToken() -> Observable<RefreshTokenModel> {
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            let authHeader = ["Content-Type": "application/json",
                              "accept": "application/json",
                              "accesstoken": "Bearer \((tokenUtils.read(account: UserDefaultKey.accessToken) ?? ""))",
                              "refreshtoken": "Bearer \((tokenUtils.read(account: UserDefaultKey.refreshToken) ?? ""))"]
            if tokenUtils.didTokenUpdate() {
                print("Loading (ꈍᴗꈍ)  ...zzzZZZ, 일반 갱신")
                return self.defaultURLSessionNetworkService.post(url: Constants.baseURL + "/auth/token",
                                                                 headers: authHeader)
                .map { result in
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(RefreshTokenModel.self, from: result.get())
                    return json
                }
            } else {
                return Observable.just(RefreshTokenModel(statusCode: 418, message: "커피 못내려"))
            }
        } else {
            return Observable.just(RefreshTokenModel(statusCode: 418, message: "커피 못내려"))
        }
    }
    
    func postForceRefreshToken() -> Observable<RefreshTokenModel> {
        let authHeader = ["Content-Type": "application/json",
                          "accept": "application/json",
                          "accesstoken": "Bearer \((tokenUtils.read(account: UserDefaultKey.accessToken) ?? ""))",
                          "refreshtoken": "Bearer \((tokenUtils.read(account: UserDefaultKey.refreshToken) ?? ""))"]
        print("Loading (ꈍᴗꈍ)  ...zzzZZZ, 강제 갱신")
            return self.defaultURLSessionNetworkService.post(url: Constants.baseURL + "/auth/token",
                                                             headers: authHeader)
            .map { result in
                let decoder = JSONDecoder()
                let json = try decoder.decode(RefreshTokenModel.self, from: result.get())
                return json
            }
    }
    
    //User의 JWT 검증 (추가)
    func postUserJWT() -> Observable<UserJWTModel> {
        let authHeader = ["Content-Type": "application/json",
                          "accept": "application/json",
                          "accesstoken": "Bearer \((tokenUtils.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.post(url: Constants.baseURL + "/auth/user",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(UserJWTModel.self, from: result.get())
            return json
        }
    }
    
    func getVerificationVersion() -> Observable<VerifivateVersionDataModel>{
        let header = ["Content-Type": "application/json",
                      "accept": "application/json"]
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/auth/version?type=ios",
                                                        headers: header)
        .map{ result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(VerifivateVersionDataModel.self, from: result.get())
            return json
        }
    }
     
}
