import Foundation
import RxCocoa
import RxSwift

final class VerifyEmailViewModel {
    weak var coordinator: VerifyEmailCoordinator?
    private var signUpRepository: AuthRepository?
    private let tokenUtils = TokenUtils()
    private var disposeBag = DisposeBag()
    var isFormComplete: Bool = false
    var isSendComplete: Bool = false
    var isComplete: Bool = false
    
    struct Input {
        let nextButtonDidTap: Observable<Void>
        let userEmail: Observable<String> 
    }
    
    struct Output {
        //이메일 처리 이후 로직
        var isEmailFormatted = PublishRelay<Bool>()
        var isEmailUnique = PublishRelay<Bool>()
        var didEmailVerifySendComplete = PublishRelay<Bool>()
        var didEmailVerifyComplete = PublishRelay<Bool>()
        var didEmailRemoved = PublishRelay<Bool>()
    }
    
    init(coordinator: VerifyEmailCoordinator, signUpRepository: AuthRepository) {
        self.coordinator = coordinator
        self.signUpRepository = signUpRepository
    }
    
    func emailVerifyTransform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.disposeBag = disposeBag
        
        input.userEmail
            .subscribe(onNext: { email in
                print(self.isFormComplete)
                if self.isFormComplete {
                    UserDefaults.standard.set(email, forKey: UserDefaultKey.email)
                    UserDefaults.standard.set(UserDefaultKey.emailVerifyType, forKey: UserDefaultKey.emailVerifyType)
                    output.isEmailFormatted.accept(true)
                }
                else {
                    output.didEmailRemoved.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        input.nextButtonDidTap
            .throttle(.seconds(2),
                      latest: false,
                      scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                //중복검사 하지 않았을 때 이메일 양식이 맞는다면
                //중복검사 하지 않았고, 이메일 발송 전이라면
                if self!.isFormComplete && !self!.isSendComplete {
                    HapticService.shared.playFeedback()
                    self?.signUpRepository?.postCheckDuplicateAuth(value: UserDefaults.standard.string(forKey: UserDefaultKey.email) ?? "",
                                                                  property: "email")
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] data in
                        if data.data.isUnique {
                            //중복되지 않은 이메일 이라면
                            //그런데 아직 인증메일을 발송하지 않았다면
                            if !self!.isSendComplete {
                                output.isEmailUnique.accept(true)
                                self!.signUpRepository?.postEmailAuthentication(dto: EmailAuthenticationDTO(type: .normal))
                                    .observe(on: MainScheduler.instance)
                                    .subscribe(onNext: { [weak self] data in
                                        if data.statusCode == 200 {
                                            self?.tokenUtils.create(account: "emailVerify", value: data.data.token)
                                            self?.isSendComplete = true
                                            output.didEmailVerifySendComplete.accept(true)
                                        } else {
                                            output.didEmailVerifySendComplete.accept(false)
                                            self?.isSendComplete = false
                                        }
                                    })
                                    .disposed(by: disposeBag)
                            }
                        } else {
                            output.isEmailUnique.accept(false)
                        }
                    })
                    .disposed(by: disposeBag)
                } else {
                    self!.signUpRepository?.getEmailAuthenticationConfirm(type: .normal)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] data in
                            //발송 성공 후 인증과정이 완료 되었다면
                            if data.data.isCompleted {
                                HapticService.shared.playFeedback()
                                self!.coordinator?.pushToNextView()
                            } else {
                                HapticService.shared.playFeedback()
                                output.didEmailVerifyComplete.accept(false)
                            }
                        })
                        .disposed(by: self!.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        return output
    }
    
}
