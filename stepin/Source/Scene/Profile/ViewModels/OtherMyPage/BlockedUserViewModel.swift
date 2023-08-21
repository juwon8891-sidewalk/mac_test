import RxSwift
import RxDataSources
import RxCocoa

final class BlockedUserViewModel {
    let tokenUtil = TokenUtils()
    var userRepository: UserRepository?
    var authRepository: AuthRepository?
    
    internal var userId: String = ""
    
    struct Input {
        let unblockButton: UIButton
        let didUnlockButtonTapped: Observable<Void>
    }
    
    struct Output {
        var unblockState = PublishRelay<Bool>()
    }
    
    init(userRepository: UserRepository, authRepository: AuthRepository) {
        self.userRepository = userRepository
        self.authRepository = authRepository
    }

    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.didUnlockButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.postBlockUser(input: input, disposeBag: disposeBag)
                output.unblockState.accept(input.unblockButton.isSelected)
            })
            .disposed(by: disposeBag)
        
        
        return output
    }
    
    //토큰 리프레시
    private func refreshTokenObserver(apiState: ProfileApiType,
                                      input: Input,
                                      disposeBag: DisposeBag) {
        let blockState = input.unblockButton.isSelected ? 1: -1
        self.authRepository?.postRefreshToken()
            .subscribe(onNext: { [weak self] result in
                switch apiState {
                case .blockUserProfile:
                    self?.userRepository?.postUserBlock(state: blockState, userId: self!.userId)
                        .subscribe(onNext: { [weak self] _ in
                        })
                        .disposed(by: disposeBag)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func postBlockUser(input: Input,
                               disposeBag: DisposeBag) {
        if tokenUtil.didTokenUpdate() {
            refreshTokenObserver(apiState: .blockUserProfile, input: input, disposeBag: disposeBag)
        } else {
            let blockState = input.unblockButton.isSelected ? 1: -1
            self.userRepository?.postUserBlock(state: blockState, userId: self.userId)
                .subscribe(onNext: { [weak self] _ in
                })
                .disposed(by: disposeBag)
        }
    }
    
    
}
