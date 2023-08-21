import Foundation
import RxCocoa
import RxSwift

final class FindPasswordViewModel {
    weak var coordinator: FindPasswordCoordinator?
    private var authRepository: AuthRepository?
    private let tokenUtils = TokenUtils()
    internal var isFormComplete: Bool = false
    internal var isSendComplete: Bool = false
    
    private var isDuplicateEmailRelay = PublishRelay<Void>()
    private var isCompleteGetTokenRelay = PublishRelay<Bool>()
    private var isCompleteConfirmRelay = PublishRelay<Bool>()

    struct Input {
        let confirmButtonTap: Observable<Void>
        let emailString: Observable<String>
    }
    
    struct Output {
        var isEmailFormatted = PublishRelay<Bool>()
        var didEmailVerifySendComplete = PublishRelay<Bool>()
        var didEmailVerifyComplete = PublishRelay<Bool>()
        var didEmailRemoved = PublishRelay<Bool>()
        var isNotExistEmail = PublishRelay<Void>()
    }
    
    init(coordinator: FindPasswordCoordinator, signUpRepository: AuthRepository) {
        self.coordinator = coordinator
        self.authRepository = signUpRepository
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.emailString
            .subscribe(onNext: { [weak self] email in
                if self!.isFormComplete {
                    UserDefaults.standard.set(email, forKey: UserDefaultKey.findPwdEmail)
                    UserDefaults.standard.set(UserDefaultKey.passwordReset, forKey: UserDefaultKey.passwordReset)
                    output.isEmailFormatted.accept(true)
                }
                else {
                    output.didEmailRemoved.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        input.confirmButtonTap
            .throttle(.seconds(2),
                      latest: false,
                      scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { _ in
                if self.isFormComplete && !self.isSendComplete {
                    HapticService.shared.playFeedback()
                    //중복 체크 진행
                    if let email = UserDefaults.standard.string(forKey: UserDefaultKey.findPwdEmail) {
                        self.didEmailDuplicate(email: email, disposeBag: disposeBag)
                    }
//
//                    self?.signUpRepository?.postEmailAuthentication(dto: EmailAuthenticationDTO(type: .findPassword))
//                        .observe(on: MainScheduler.instance)
//                        .subscribe(onNext: { [weak self] data in
//                            self?.tokenUtils.create(account: "findEmailVerify", value: data.data.token)
//                            output.didEmailVerifySendComplete.accept(true)
//                            self?.isSendComplete = true
//                        }, onError: { [weak self] _ in
//                            output.didEmailVerifySendComplete.accept(false)
//                            self?.isSendComplete = false
//                        })
//                        .disposed(by: disposeBag)
                    
                }
                else if self.isFormComplete && self.isSendComplete {
                    HapticService.shared.playFeedback()
                    self.getConfirmToEmail(disposeBag: disposeBag)
//                    self?.signUpRepository?.getEmailAuthenticationConfirm(type: .findPassword)
//                        .observe(on: MainScheduler.instance)
//                        .subscribe(onNext: { [weak self] result in
//                            if result.data.isCompleted {
//                                output.didEmailVerifyComplete.accept(true)
//                                self?.coordinator?.pushToNextView()
//                            } else {
//                                output.didEmailVerifyComplete.accept(false)
//                            }
//                        }, onError: { [weak self] _ in
//                            output.didEmailVerifyComplete.accept(false)
//                        })
//                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        isCompleteGetTokenRelay
            .withUnretained(self)
            .bind(onNext: { (_, state) in
                output.didEmailVerifySendComplete.accept(state)
            })
            .disposed(by: disposeBag)
        
        isCompleteConfirmRelay
            .withUnretained(self)
            .bind(onNext: { (_, state) in
                output.didEmailVerifyComplete.accept(state)
            })
            .disposed(by: disposeBag)
        
        isDuplicateEmailRelay
            .withUnretained(self)
            .bind(onNext: { _ in
                output.isNotExistEmail.accept(())
            })
            .disposed(by: disposeBag)

        return output
    }
    
    private func didEmailDuplicate(email: String,
                                   disposeBag: DisposeBag) {
        //이메일 중복 체크 후 중복이 아니라면 인증 이메일 발송
        
        self.authRepository?.postCheckDuplicateAuth(value: email, property: "email")
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                if !data.data.isUnique {
                    self.postEmailVerify(disposeBag: disposeBag)
                } else {
                    //어 돼~
                    self.isDuplicateEmailRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
    private func postEmailVerify(disposeBag: DisposeBag) {
        self.authRepository?.postEmailAuthentication(dto: EmailAuthenticationDTO(type: .findPassword))
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                self.tokenUtils.create(account: "findEmailVerify", value: data.data.token)
                self.isCompleteGetTokenRelay.accept(true)
                self.isSendComplete = true
            }, onError: { _ in
                self.isCompleteGetTokenRelay.accept(false)
                self.isSendComplete = false
            })
            .disposed(by: disposeBag)
    }
    
    private func getConfirmToEmail(disposeBag: DisposeBag) {
        self.authRepository?.getEmailAuthenticationConfirm(type: .findPassword)
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                DispatchQueue.main.async {
                    if result.data.isCompleted {
                        self.isCompleteConfirmRelay.accept(true)
                        self.coordinator?.pushToNextView()
                    } else {
                        self.isCompleteConfirmRelay.accept(false)
                    }
                }
            }, onError: { _ in
                self.isCompleteConfirmRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
