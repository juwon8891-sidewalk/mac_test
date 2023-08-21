import Foundation
import RxSwift
import RxRelay
import RxDataSources
import AVFoundation
import Lottie

final class GameResultViewModel: NSObject {
    var disposeBag: DisposeBag?
    var coordinator: GameResultCoordinator?
    var gameResultUseCase = GameResultUseCase()
    var input: Input?
    
    var scoreData: [String]?
    var score: Float?
    var danceInfo: PlayDance?
    
    init(coordinator: GameResultCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidAppear
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if let scoreData = vm.scoreData, let score = vm.score {
                    output.scoreOutput.accept((scoreData, String(score)))
                }
                
                if let danceInfo = vm.danceInfo {
                    output.musicData.accept([danceInfo.coverURL,
                                             danceInfo.title,
                                             danceInfo.artist])
                }
                
                if let score = vm.score, let danceData = vm.danceInfo {
                    vm.gameResultUseCase.getExpectedRank(danceId: danceData.danceID,
                                                         score: score)
                        .withUnretained(self)
                        .bind(onNext: { (vm, result) in
                            output.rankData.accept(result)
                        })
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.continueButtonTapped
            .debug()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if let danceData = vm.danceInfo {
                    output.continueButtonTap.accept(danceData)
                }
            })
            .disposed(by: disposeBag)
        
        input.doneButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                vm.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        input.alertViewOkButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.isAlertOkButtonTapped.accept(())
                if let data = vm.danceInfo {
                    vm.coordinator?.pop()
                    vm.coordinator?.pushToChallengeGameView(danceData: data)
                }
            })
            .disposed(by: disposeBag)
        
        input.alertViewCancelButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.isAlertCancelButtonTapped.accept(())
            })
            .disposed(by: disposeBag)
        
        
        return output
    }
    
    struct Input {
        var viewDidAppear: Observable<Void>
        var continueButtonTapped: Observable<Void>
        var doneButtonTapped: Observable<Void>
        var alertViewOkButtonTapped: Observable<Void>
        var alertViewCancelButtonTapped: Observable<Void>
    }

    struct Output {
        var scoreOutput = PublishRelay<([String], String)>()
        var rankData = PublishRelay<[Int]>()
        var musicData = PublishRelay<[String]>()
        var continueButtonTap = PublishRelay<PlayDance>()
        var isAlertCancelButtonTapped = PublishRelay<Void>()
        var isAlertOkButtonTapped = PublishRelay<Void>()
    }
}
