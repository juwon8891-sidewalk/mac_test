import Foundation
import RxCocoa
import RxSwift
import SDSKit

enum InduceLoginType {
    case play
    case history
    case profile
}

final class InduceLoginViewModel {
    weak var coordinator: InduceLoginCoordinator?
    var viewType: InduceLoginType?

    struct Input {
        let viewDidAppear: Observable<Void>
        let signUpButtonTapped: Observable<Void>
    }
    
    struct Output {
        var iconImageData = PublishRelay<UIImage>()
        var titleData = PublishRelay<String>()
    }
    
    init(coordinator: InduceLoginCoordinator, type: InduceLoginType) {
        self.coordinator = coordinator
        self.viewType = type
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                switch self.viewType {
                case .play:
                    output.titleData.accept("induce_login_play_game_title".localized())
                    output.iconImageData.accept(SDSIcon.icPlayActive)
                case .history:
                    output.titleData.accept("induce_login_history_title".localized())
                    output.iconImageData.accept(SDSIcon.icHistoryActive)
                case .profile:
                    output.titleData.accept("induce_login_mypage_title".localized())
                    output.iconImageData.accept(SDSIcon.icMyProfileActive)
                case .none:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        input.signUpButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.coordinator?.pushToLoginView()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    
}
