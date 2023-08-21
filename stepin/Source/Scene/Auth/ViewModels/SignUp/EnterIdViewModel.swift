import Foundation
import RxCocoa
import RxSwift


final class EnterIdViewModel {
    weak var coordinator: EnterIdCoordinator?
    private var signUpRepository: AuthRepository?
    var isComplete: Bool = false
    
    let tokenUtils = TokenUtils()

    struct Input {
        let textField: BaseTextField
        let nextButtonDidTap: Observable<Void>
    }
    
    struct Output {
        var currentIDState = BehaviorRelay<TextFieldState>(value: .empty)
        var indicatorStatus = BehaviorRelay<Bool>(value: false)
        var toastMessage = PublishRelay<String>()
        var checkDuplicateAuth = BehaviorSubject<Bool>(value: false)
        var isTextFieldClear = PublishRelay<Bool>()
    }
    
    init(coordinator: EnterIdCoordinator, signUpRepository: AuthRepository) {
        self.coordinator = coordinator
        self.signUpRepository = signUpRepository
    }
    
    func getIdTransform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.textField.rx.text.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, pwd) in
                if pwd == "" {
                    output.isTextFieldClear.accept(true)
                } else {
                    output.isTextFieldClear.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        input.nextButtonDidTap
            .observe(on: MainScheduler.instance)
            .bind(onNext: { _ in
                output.indicatorStatus.accept(true)
                self.postCheckDuplicateAuth(output: output, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        return output
    }
    
    func postCheckDuplicateAuth(output: Output, disposeBag: DisposeBag) {
        self.signUpRepository?.postCheckDuplicateAuth(value: UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) ?? "", property: "identifiername")
            .withUnretained(self)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: { viewModel, data in
            
            if data.data.isUnique { //중복 되지 않았을 때
                //회원가입 진행 후 로그인으로 푸쉬
                // 이메일 회원가입 시도
                switch AuthLoginInfo.type {
                case AuthLoginInfo.emailType :
                    viewModel.postEmailSignUp(output: output, disposeBag: disposeBag)
                case AuthLoginInfo.googleType:
                    viewModel.postSocialSignUp(type: AuthLoginInfo.type,
                                               email: AuthLoginInfo.googleEmail,
                                               accessToken: viewModel.tokenUtils.read(account: AuthLoginInfo.googleAccessToken) ?? "",
                                               password: AuthLoginInfo.password,output: output, disposeBag: disposeBag)
                case AuthLoginInfo.facebookType:
                    viewModel.postSocialSignUp(type: AuthLoginInfo.type,
                                               email: AuthLoginInfo.facebookEmail,
                                               accessToken: viewModel.tokenUtils.read(account: AuthLoginInfo.facebookAccessToken) ?? "",
                                               password: AuthLoginInfo.password, output: output, disposeBag: disposeBag)
                case AuthLoginInfo.appleType:
                    viewModel.postSocialSignUp(type: AuthLoginInfo.type,
                                               email: UserDefaults.standard.string(forKey: AuthLoginInfo.appleEmail) ?? "",
                                               accessToken: viewModel.tokenUtils.read(account: AuthLoginInfo.appleAccessToken) ?? "",
                                               password: AuthLoginInfo.password, output: output, disposeBag: disposeBag)
                default:
                    break
                }
            } else {
                output.currentIDState.accept(.unformatted_dupplicated_id)
            }
        },onError: {  _ in
            output.indicatorStatus.accept(false)
        })
        .disposed(by: disposeBag)
    }
    // 이메일 회원가입
    func postEmailSignUp(output: Output, disposeBag: DisposeBag) {
        self.signUpRepository?.postEmailSignUp()
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { viewModel, data in
                print("회원가입후 상태코드:", data.statusCode)
                if data.statusCode == 200 { //회원가입 성공하였으므로 바로 로그인 시도
                    viewModel.postEmailSignIn(output: output, disposeBag: disposeBag)
                }
            }, onError: {  _ in
                output.indicatorStatus.accept(false)
                output.toastMessage.accept("500 Internal Server Error")
            })
            .disposed(by: disposeBag)
    }
    // 이메일 로그인
    func postEmailSignIn(output: Output, disposeBag: DisposeBag) {
        self.signUpRepository?.postEmailSignIn(email: UserDefaults.standard.string(forKey: UserDefaultKey.email) ?? "",
                                               password: UserDefaults.standard.string(forKey: UserDefaultKey.password) ?? "")
        .withUnretained(self)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: { viewModel,data in
            // 로그인 성공하므로 홈 화면전환
            UserDefaults.standard.set(true, forKey: "LoginStatus")
            UserDefaults.standard.set(data.data?.identifierName, forKey: UserDefaultKey.identifierName)
            UserDefaults.standard.set(data.data?.userID, forKey: UserDefaultKey.userId)
            UserDefaults.standard.set(data.data?.name, forKey: UserDefaultKey.name)
            UserDefaults.standard.set(data.data?.profileURL, forKey: UserDefaultKey.profileUrl)
            output.indicatorStatus.accept(false)
            viewModel.coordinator?.homeMove()
        },onError: {  _ in
            output.indicatorStatus.accept(false)
        })
        .disposed(by: disposeBag)
    }
    // 소셜 회원가입
    func postSocialSignUp(type: String, email: String, accessToken: String, password: String, output: Output, disposeBag: DisposeBag) {
        self.signUpRepository?.postSocialSignUp(LoginType: type,
                                                accessToken: accessToken)
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { viewModel, data in
                print("회원가입후 요청:", data)
                viewModel.postSocialSignIn(type: type, accessToken: accessToken, email: email, password: password, output: output, disposeBag: disposeBag)
                }, onError: {  _ in
                    output.indicatorStatus.accept(false)
                    output.toastMessage.accept("500 Internal Server Error")
            })
            .disposed(by: disposeBag)
    }
    // 소셜 로그인
    func postSocialSignIn(type: String, accessToken: String, email: String, password: String, output: Output, disposeBag: DisposeBag) {
        self.signUpRepository?.postSocialSignIn(type: type,
                                                    accessToken: accessToken)
        .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { viewModel,  data in
                // 로그인 성공하므로 홈 화면전환
                print("로그인 성공후 실행")
                UserDefaults.standard.set(true, forKey: "LoginStatus")
                UserDefaults.standard.set(data.data?.identifierName, forKey: UserDefaultKey.identifierName)
                UserDefaults.standard.set(data.data?.userID, forKey: UserDefaultKey.userId)
                UserDefaults.standard.set(data.data?.name, forKey: UserDefaultKey.name)
                UserDefaults.standard.set(data.data?.profileURL, forKey: UserDefaultKey.profileUrl)
                viewModel.coordinator?.homeMove()
            },onError: { _ in
                output.indicatorStatus.accept(false)
                output.toastMessage.accept("500 Internal Server Error")
            })
            .disposed(by: disposeBag)
    }
}
