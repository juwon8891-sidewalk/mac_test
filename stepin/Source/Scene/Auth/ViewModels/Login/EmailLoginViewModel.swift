import Foundation
import RxCocoa
import RxSwift

final class EmailLoginViewModel {
    weak var coordinator: EmailLoginCoordinator?
    private var signUpRepository: AuthRepository?
    private var email: String = ""
    private var password: String = ""
    private var type: String = ""

    var isComplete: Bool = false
    
    struct Input {
        let didForgotPwdButtonTap: Observable<Void>
        let didLoginButtonTap: Observable<Void>
        let emailString: Observable<String>
        let passwordString: Observable<String>
    }
    
    struct Output {
        //로그인 실패시의 output
        var loginFailed = PublishRelay<Bool>()
    }
    
    init(coordinator: EmailLoginCoordinator, signUpRepository: AuthRepository) {
        self.coordinator = coordinator
        self.signUpRepository = signUpRepository
    }
    
    func emailLoginTransform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        
        input.emailString
            .subscribe(onNext: { [weak self] email in
                self!.email = email
            })
            .disposed(by: disposeBag)
        
        input.passwordString
            .subscribe(onNext: { [weak self] pwd in
                self!.password = pwd
            })
            .disposed(by: disposeBag)

        input.didForgotPwdButtonTap
            .subscribe(onNext: { [weak self] in
                HapticService.shared.playFeedback()
                self?.coordinator?.pushToFindPasswordView()
            })
            .disposed(by: disposeBag)
        
        input.didLoginButtonTap
            .subscribe(onNext: { [weak self] in
                if self!.isComplete {
                    HapticService.shared.playFeedback()
                    self?.signUpRepository?.postEmailSignIn(email: self!.email, // 수정된 부분
                                                            password: self!.password)
                    .debug()
                    .subscribe(onNext: { [weak self] result in
                        //유저디폴트 저장 안될때
                        UserDefaults.standard.set(result.data?.userID, forKey: UserDefaultKey.userId)
                        UserDefaults.standard.set(result.data?.identifierName, forKey: UserDefaultKey.identifierName)
                        UserDefaults.standard.set(result.data?.name, forKey: UserDefaultKey.name)
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.LoginStatus) // 로그인 상태 저장
                        if let profileUrl = result.data?.profileURL {
                            UserDefaults.standard.set(profileUrl, forKey: UserDefaultKey.profileUrl)
                        }
                        output.loginFailed.accept(false)
                    }, onError: { error in
                        output.loginFailed.accept(true)
                    })
                    .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
    
        
        return output
    }
}
