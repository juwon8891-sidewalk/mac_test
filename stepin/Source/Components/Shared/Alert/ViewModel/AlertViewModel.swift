import Foundation
import RxCocoa
import RxSwift

final class AlertViewModel {
    private var alertView = UIView()
    let authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    let userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    let videoRepository = VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    var userId: String = ""
    var videoId: String = ""
    
    var isReportCompleteRelay = PublishRelay<Void>()
    
    struct Input {
        let hateSpeachButtonTapped: Observable<Void>
        let spamMessageButtonTapped: Observable<Void>
        let NudityButtonTapped: Observable<Void>
        let fraudButtonTapped: Observable<Void>
        let cancelButtonTap: Observable<Void>
    }
    struct Output {
        var didCancelButtonTapped = PublishRelay<Void>()
        var isReportComplete = PublishRelay<Void>()
    }
    
    init(alertView: UIView) {
        self.alertView = alertView
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.hateSpeachButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.postReportUser(content: "alert_report_dont_like".localized(),
                                    input: input,
                                    disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.spamMessageButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.postReportUser(content: "alert_report_spam".localized(),
                                    input: input,
                                    disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.NudityButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.postReportUser(content: "alert_report_naked".localized(),
                                    input: input,
                                    disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.fraudButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.postReportUser(content: "alert_report_fraoud".localized(),
                                    input: input,
                                    disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.cancelButtonTap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                output.didCancelButtonTapped.accept(())
            })
            .disposed(by: disposeBag)
        
        self.isReportCompleteRelay
            .withUnretained(self)
            .subscribe(onNext: { _ in
                output.isReportComplete.accept(())
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func postReportUser(content: String,
                        input: Input,
                        disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.userRepository.postReportUser(userId: self.userId,
                                                               content: content)}
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                self.isReportCompleteRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
}
