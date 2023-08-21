import RxSwift
import RxRelay

final class EditMyPageTextFieldViewModel {
    internal var type: EditMyPageTextFieldType?
    private var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private let tokenUtils = TokenUtils()
    
    
    private var idState: TextFieldState = .formatted_id
    private var nickNameState: TextFieldState = .formatted_nickname
    
    struct Input {
        let didTextFieldEditting: Observable<String>
    }
    
    struct Output {
        var currentTextFieldState = PublishRelay<TextFieldState>()
    }
    
    init(type: EditMyPageTextFieldType) {
        self.type = type
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        
        input.didTextFieldEditting
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text in
                switch self?.type {
                case .stepinId:
                    //조건이 왜 안맞을까>?
                    if text == UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) { //내 원래 아이디일경우에는 걍 사용중인 아이디로 만들어버림
                        //내 원래 아이디 일때
                        output.currentTextFieldState.accept(.formatted_use_nickname)
                    } else {
                        if text.count >= 5 && text.isContainNumberAndAlphabet() { //5자이상 && 영어 알파벳 구성
                            output = self!.checkDuplicatedStepinId(input: input,
                                                                   disposeBag: disposeBag,
                                                                   id: text,
                                                                   output: output)
                        } else {
                            output.currentTextFieldState.accept(.unformatted_id)
                        }
                    }
                case .nickName:
                    if text == UserDefaults.standard.string(forKey: UserDefaultKey.name) {
                        output.currentTextFieldState.accept(.formatted_use_nickname)
                    } else {
                        if text.count >= 5 { //8자 이상
                            output.currentTextFieldState.accept(.formatted_nickname)
                        } else {
                            output.currentTextFieldState.accept(.unformatted_nickname)
                        }
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    //토큰 리프레시
    private func refreshTokenObserver(input: Input,
                                      disposeBag: DisposeBag,
                                      id: String,
                                      output: Output) {
        self.authRepository.postRefreshToken()
            .subscribe(onNext: { [weak self] result in
                self?.authRepository.postCheckDuplicateAuth(value: id, property: "identifiername")
                    .subscribe(onNext: { [weak self] result in
                        if result.data.isUnique {
                            output.currentTextFieldState.accept(.formatted_id)
                        } else {
                            output.currentTextFieldState.accept(.unformatted_dupplicated_id)
                        }
                    }, onError: { [weak self] _ in
                        self?.idState = .fail_network
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    private func checkDuplicatedStepinId(input: Input, disposeBag: DisposeBag, id: String, output: Output) -> Output {
        if tokenUtils.didTokenUpdate() {
            self.refreshTokenObserver(input: input, disposeBag: disposeBag, id: id, output: output)
        } else {
            self.authRepository.postCheckDuplicateAuth(value: id, property: "identifiername")
                .subscribe(onNext: { [weak self] result in
                    if result.data.isUnique {
                        output.currentTextFieldState.accept(.formatted_id)
                    } else {
                        output.currentTextFieldState.accept(.unformatted_dupplicated_id)
                    }
                }, onError: { [weak self] _ in
                    self?.idState = .fail_network
                })
                .disposed(by: disposeBag)
        }
        return output
    }
    
    
    
}
