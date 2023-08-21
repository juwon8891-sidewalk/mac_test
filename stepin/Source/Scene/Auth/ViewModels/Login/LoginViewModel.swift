import Foundation
import RxCocoa
import RxSwift

import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FacebookLogin
import AuthenticationServices
import CryptoKit
import GTMSessionFetcher


final class LoginViewModel {
    
    weak var coordinator: LoginCoordinator?
    weak var termViewModel: TermsViewModel?
    
    private var signInRepository: AuthRepository? // 추가
    let tokenUtils = TokenUtils()

    var currentNonce: String?
    
    struct Input {
        let googleLoginButtonDidTap: Observable<Void>
        let faceBookLoginButtonDidTap: Observable<Void>
        let appleLoginButtonDidTap: Observable<Void>
        let emailLoginButtonDidTap: Observable<Void>
        let loginWithEmailButtonDidTap: Observable<Void>
        let backButtonDidTap: Observable<Void>
    }
    
    struct Output {
        //로그인 실패시의 output
        var indicatorStatus = BehaviorRelay<Bool>(value: false)
        var toastMessage = PublishRelay<String>()
    }
    
    init(coordinator: LoginCoordinator, signInRepository: AuthRepository) {
        self.coordinator = coordinator
        self.signInRepository = signInRepository // 추가
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output{
        
        let output = Output()
        
        input.googleLoginButtonDidTap.subscribe(onNext: { [weak self] in
            HapticService.shared.playFeedback()
            self?.requestGoogleLogin(output: output)
        })
        .disposed(by: disposeBag)
        
        input.faceBookLoginButtonDidTap.subscribe(onNext: { [weak self] in
            HapticService.shared.playFeedback()
            self?.requestFacebookLogin(output: output)
        })
        .disposed(by: disposeBag)
        
        input.appleLoginButtonDidTap.subscribe(onNext: { [weak self] in
            HapticService.shared.playFeedback()
            self?.requestAppleLogin()
        })
        .disposed(by: disposeBag)
        
        input.emailLoginButtonDidTap.subscribe(onNext: { [weak self] in
            HapticService.shared.playFeedback()
            AuthLoginInfo.isSocialLogin = false
            AuthLoginInfo.type = AuthLoginInfo.emailType
            self?.coordinator?.pushToTermView()
        })
        .disposed(by: disposeBag)
        
        input.loginWithEmailButtonDidTap.subscribe(onNext: { [weak self] in
            HapticService.shared.playFeedback()
            self?.coordinator?.doEmailLogin()
        })
        .disposed(by: disposeBag)
        
        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
extension LoginViewModel {
    private  func requestGoogleLogin(output: Output) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self.coordinator?.loginViewController ?? LoginVC()) { user, error in
            output.indicatorStatus.accept(true)
            if let error = error {
                // 로그인 실패 처리
                print("google 로그인 실패 : \(error.localizedDescription)")
                self.coordinator?.loginViewController.lottieIndicator.stop()
                return
            }
            guard error == nil else { return }
            guard let accessToken = user?.user.accessToken.tokenString else {return}
            guard let idToken = user?.user.idToken?.tokenString else {return}

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    // 로그인 실패 처리
                    print("Firebase 인증 실패: \(error.localizedDescription)")
                }
                guard let email = authResult?.user.email else {return}
                self?.tokenUtils.create(account: AuthLoginInfo.googleAccessToken, value: accessToken)
                
                AuthLoginInfo.googleEmail = email
                AuthLoginInfo.type = AuthLoginInfo.googleType
                self?.signIn(type: AuthLoginInfo.type,
                             accessToken: self?.tokenUtils.read(account: AuthLoginInfo.googleAccessToken) ?? "",
                             email: AuthLoginInfo.googleEmail,
                             password: AuthLoginInfo.password,
                             output: output)
            }
        }
    }
    
    // AuthRepository 의 signIn과 중첩되므로 나중에 수정
    func signIn(type: String, accessToken: String, email: String, password: String, output: Output)  {
        
        self.signInRepository?.postSocialSignIn(type: type, accessToken: accessToken)
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
           .subscribe(onNext: {  viewModel, data in
               print(data)
               output.indicatorStatus.accept(false)
               // 로그인 성공하므로 홈 화면전환
               switch data.statusCode {
               case 200:
                       if type == AuthLoginInfo.appleType { // 애플로그인 여부를 SceneDelegate에서 identifier로 판단하기위해 필요
                           let identifier = viewModel.tokenUtils.read(account: "tempuserIdentifier")
                           viewModel.tokenUtils.create(account: "userIdentifier", value: identifier ?? "")
                       }
                   UserDefaults.standard.set(data.data?.identifierName, forKey: UserDefaultKey.identifierName)
                   UserDefaults.standard.set(data.data?.userID, forKey: UserDefaultKey.userId)
                   UserDefaults.standard.set(data.data?.name, forKey: UserDefaultKey.name)
                   UserDefaults.standard.set(data.data?.profileURL, forKey: UserDefaultKey.profileUrl)
                   UserDefaults.standard.set(true, forKey: "LoginStatus") // 로그인 상태 저장
                   viewModel.coordinator?.homeMove()
               case 400:
                   // 신규회원이라 약관동의 페이지 이동
                       AuthLoginInfo.isSocialLogin = true // birthday Or emailVerify 화면전환위해 필요
                   viewModel.coordinator?.pushToTermView()
               case 403:
                   //  jwt 검사후 만료가 되었으면 토큰갱신 시도
                   viewModel.userJWTAfterTokenUpdate()
               case 500:
                   output.toastMessage.accept("500 Server Error")
               default:
                   break
               }
           }, onError: { error in
               print(error)
               output.indicatorStatus.accept(false)
               output.toastMessage.accept("Error")
            })
           .disposed(by: (self.coordinator?.loginViewController.disposeBag)!)
    }
    
    // 토큰이 만료가 되었는지 아닌지 판단후 갱신
    private func userJWTAfterTokenUpdate() {
        self.signInRepository?.postUserJWT()
               .subscribe(onNext: { data in
                    print("토큰만료 안됨, 상태코드:",data.statusCode)
               }, onError: { error in
                   // 토큰이 만료되서 갱신!!
                   self.signInRepository?.postRefreshToken()
                       .bind(onNext: { data in
                           print("토큰갱신 성공:",data.statusCode)
                       })
                       .disposed(by: (self.coordinator?.loginViewController.disposeBag)!)
               })
               .disposed(by: (self.coordinator?.loginViewController.disposeBag)!)
    }
    
    private func requestFacebookLogin(output: Output) {
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile", "email"], from: self.coordinator?.loginViewController ?? LoginVC()) { (result, error) in
            output.indicatorStatus.accept(true)
            if error != nil {
                print("Error during Facebook login .: \(String(describing: error?.localizedDescription))")
            }
            guard let result = result else {
                print("No facebook Result")
                self.coordinator?.loginViewController.lottieIndicator.stop()
                return
            }
            if result.isCancelled {
                print("Login Cancelld")
                self.coordinator?.loginViewController.lottieIndicator.stop()
                manager.logOut()
                return
            }
            GraphRequest(graphPath: "me", parameters: ["fields": "email"]).start(completionHandler: { (connection, result, error) -> Void in
                    guard error == nil else {return}
                    guard let facebook = result as? [String: Any] else { return }
//                    guard let email = facebook["email"] as? String else{
//                        self.coordinator?.loginViewController.view.makeToast(title: "Facebook Email이 존재하지 않아, 회원가입을 진행 할 수 없습니다", type: .redX)
//                        return
//                    }
                    if let accessToken = AccessToken.current, !accessToken.isExpired {
                        print("Facebook Access Tocken: \(accessToken.tokenString)")
                        self.tokenUtils.create(account: AuthLoginInfo.facebookAccessToken,
                                               value: accessToken.tokenString)
//                        UserDefaults.standard.set(accessToken.tokenString, forKey: AuthLoginInfo.facebookAccessToken)
                        AuthLoginInfo.type = AuthLoginInfo.facebookType
//                        AuthLoginInfo.facebookEmail = email
                        self.signIn(type: AuthLoginInfo.type,
                                    accessToken: accessToken.tokenString,
                                    email: AuthLoginInfo.facebookEmail + "@.gmail.com",
                                    password: AuthLoginInfo.password,
                        output: output)
                    }
            })
        }
    }
    
    private func requestAppleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self.coordinator?.loginViewController
        authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
}

// 애플로그인 관련
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate {
    // 성공 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = loginViewModel?.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            guard let accessToken = String(data: appleIDCredential.authorizationCode!, encoding: .utf8) else {return}
            
            loginViewModel?.tokenUtils.create(account: appleIDCredential.user, value: "tempuserIdentifier")
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                               rawNonce: nonce,
                                                               fullName: appleIDCredential.fullName)
            self.lottieIndicator.play()
                // 애플에서는 처음 딱한번만 email을 줌
                if appleIDCredential.email != nil {
                    UserDefaults.standard.set(appleIDCredential.email, forKey: AuthLoginInfo.appleEmail)
                }
            
            self.loginViewModel?.tokenUtils.create(account: AuthLoginInfo.appleAccessToken, value: idTokenString)
            // 나중에 로그아웃시 AuthloginInfo.appleEmail도 같이 "" 처리
            AuthLoginInfo.type = AuthLoginInfo.appleType
            self.loginViewModel?.signIn(type: AuthLoginInfo.type,
                                        accessToken: self.loginViewModel?.tokenUtils.read(account: AuthLoginInfo.appleAccessToken) ?? "",
                                        email: UserDefaults.standard.string(forKey: AuthLoginInfo.appleEmail) ?? "not email",
                                        password: AuthLoginInfo.password, output: LoginViewModel.Output())
        }
    }

    // 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("APPLE LOGIN fali: \(error)")
    }
}
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
