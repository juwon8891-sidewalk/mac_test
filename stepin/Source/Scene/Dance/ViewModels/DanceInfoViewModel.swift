import UIKit
import RxSwift
import RxRelay

final class DanceInfoViewModel {
    let tokenUtil = TokenUtils()
    var danceRepository = DanceRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var danceId: String = ""
    
    init(danceId: String) {
        self.danceId = danceId
    }
    
    struct Input {
        let progressBar: MusicProgressBar
    }
    
    struct Output {
        var musicCoverImagePath = PublishRelay<String>()
        var musicName = PublishRelay<String>()
        var singerName = PublishRelay<String>()
        var isAnimateViewPlay = PublishRelay<Bool>()
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        input.progressBar.musicPlayButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                if input.progressBar.musicPlayButton.isSelected {
                    input.progressBar.musicPlayer?.pause()
                    output.isAnimateViewPlay.accept(false)
                } else {
                    input.progressBar.musicPlayer?.play()
                    output.isAnimateViewPlay.accept(true)
                }
                input.progressBar.musicPlayButton.isSelected = !input.progressBar.musicPlayButton.isSelected
            })
            .disposed(by: disposeBag)
        
        output = getInfoDanceData(input: input,
                                  disposeBag: disposeBag,
                                  output: output)
        return output
    }
    
    
    private func getInfoDanceData(input: Input,
                                  disposeBag: DisposeBag,
                                  output: Output) -> Output {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository.getDanceInfo(danceId: self!.danceId))!}
            .subscribe(onNext: { [weak self] result in
                output.musicCoverImagePath.accept(result.data.coverURL)
                output.musicName.accept(result.data.title)
                output.singerName.accept(result.data.artist)
                input.progressBar.setMusicPlayer(musicPath: result.data.musicURL,
                                                 startTime: Float(result.data.startTime),
                                                 endTime: Float(result.data.endTime))
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
