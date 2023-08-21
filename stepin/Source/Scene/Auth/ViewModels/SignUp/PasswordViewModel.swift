import Foundation
import RxCocoa
import RxSwift

final class PasswordViewModel {
    weak var coordinator: PasswordCoordinator?
    private var Repository: AuthRepository?
    var isComplete: Bool = false

    internal var viewType: AuthViewType?
    

    struct Input {
        let nextButtonDidTap: Observable<Void>
        let passwordTextFieldInPut: Observable<String>
    }
    
    struct Output {
        var didResetPasswordState = PublishRelay<Bool>()
        var passwoardTextFieldOut = PublishRelay<String>()
    }
    
    init(coordinator: PasswordCoordinator, repository: AuthRepository) {
        self.coordinator = coordinator
        self.Repository = repository
    }
    
    func passwordTransform(from input: Input, disposeBag: DisposeBag) -> Output{
        let output = Output()
        
        input.nextButtonDidTap
            .subscribe(onNext: {
                if self.isComplete && self.viewType != .resetPassword{
                    HapticService.shared.playFeedback()
                    self.coordinator?.pushToNextView()
                }
                else if self.isComplete && self.viewType == .resetPassword {
                    HapticService.shared.playFeedback()
                    self.Repository?.postResetPassword()
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] result in
                            self?.coordinator?.pushToLoginView()
                        }, onError: { [weak self] error in
                            output.didResetPasswordState.accept(false)
                        })
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.passwordTextFieldInPut
            .bind { text in
                output.passwoardTextFieldOut.accept(text)
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
}
