import UIKit
import Then
import SnapKit

class MusicProgressBar: UIView {
    internal var musicPlayer: MusicPlayer?
    private var startTime: Float?
    private var endTime: Float?
    private var isSeeking: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(size: CGSize) {
        super.init(frame: .init(origin: .zero, size: size))
        self.setLayout()
    }
    
    internal func setMusicPlayer(musicPath: String,
                                 startTime: Float,
                                 endTime: Float) {
        self.startTime = startTime
        self.endTime = endTime
        self.musicPlayer = MusicPlayer(musicPath: musicPath,
                                       startTime: startTime,
                                       endTime: endTime)
        self.musicPlayer?.delegate = self
        DispatchQueue.main.async {
            self.musicProgressBar.maximumValue = 1
            self.musicProgressBar.minimumValue = 0
        }
    }
    
    
    
    private func setTimeLabel(time: Float) {
        if time > 60 { //1분 이상시
            let minute: Int = Int(floor(time / 60))
            let second: Int = max(Int(time) - (60 * minute), 0)
            self.musicPlayTimeLabel.text = "\(minute):\(second)"
        } else {
            if time < 10 {
                self.musicPlayTimeLabel.text = "0:0\(Int(time))"
            } else {
                self.musicPlayTimeLabel.text = "0:\(Int(time))"
            }
            
        }
    }
    
    private func setLayout() {
        self.addSubviews([musicPlayButton, musicProgressBar, musicPlayTimeLabel])
        musicPlayButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        musicProgressBar.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(musicPlayButton.snp.trailing).offset(ScreenUtils.setWidth(value: 16))
            $0.trailing.equalTo(musicPlayTimeLabel.snp.leading).inset(ScreenUtils.setWidth(value: -16))
        }
        musicPlayTimeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
            $0.width.equalTo(ScreenUtils.setWidth(value: 30))
        }
    }
    @objc private func didSliderValueChange(_ slider: UISlider) {
        guard let musicPlayer else {return}
        if slider.isTracking {
            isSeeking = true
            self.musicPlayer?.pause()
            self.musicPlayButton.isSelected = musicPlayer.isPlaying
        } else {
            isSeeking = false
            if let endTime, let startTime {
                self.musicPlayer?.setTimeToMusic(time: (slider.value * (endTime - startTime)) + startTime) { [weak self] _ in
                    guard let strongSelf = self else {return}
                    strongSelf.musicPlayer?.play()
                    strongSelf.musicPlayButton.isSelected = musicPlayer.isPlaying
                }
            }
        }
    }
    
    internal var musicPlayButton = UIButton().then {
        $0.setBackgroundImage(ImageLiterals.icMusicPlay, for: .normal)
        $0.setBackgroundImage(ImageLiterals.icMusicPause, for: .selected)
    }
    private var musicProgressBar = UISlider().then {
        $0.addTarget(self,
                     action: #selector(didSliderValueChange(_:)),
                     for: .valueChanged)
        $0.setThumbImage(ImageLiterals.icSliderThumb, for: .normal)
        $0.minimumTrackTintColor = .PrimaryWhiteNormal
        $0.maximumTrackTintColor = .PrimaryWhiteAlternative
    }

    private var musicPlayTimeLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
        $0.text = "0:00"
    }
}

extension MusicProgressBar: MusicPlayerProtocol {
    func getCurrentMusicTime(_ time: CGFloat) {
        guard let startTime = self.startTime else {return}
        guard let endTime = self.endTime else {return}
        
        
        //현재 프로그래스 바 설정
        self.setTimeLabel(time: (Float(time) - startTime))
        self.musicProgressBar.setValue((Float(time) - startTime) / (endTime - startTime), animated: true)
        if Float(time) >= endTime {
            if !isSeeking {
                isSeeking = true
                self.musicPlayer?.pause()
                self.musicPlayer?.setTimeToMusic(time: startTime) { [weak self] _ in
                    guard let strongSelf = self else {return}
                    strongSelf.musicPlayer?.play()
                }
            }
        }
    }
}
