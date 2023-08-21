import Foundation
import UIKit
import SDSKit
import SnapKit
import Then

final class PracticePlayView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([playButton, rewindButton, rewindStateLabel, forwardButton, forwardStateLabel, startTimeLabel, videoSlider, endTimeLabel])
        
        videoSlider.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(24.adjusted)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(268.adjusted)
            $0.height.equalTo(32.adjusted)
        }
        videoSlider.layer.borderWidth = 2
        videoSlider.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        videoSlider.layer.cornerRadius = 5.adjusted
        videoSlider.clipsToBounds = true
        
        startTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(videoSlider.snp.leading)
            $0.centerY.equalTo(videoSlider)
        }
        endTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(videoSlider.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(videoSlider)
        }
        playButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(videoSlider.snp.top).inset(-24.adjusted)
            $0.width.height.equalTo(48.adjusted)
        }
        forwardButton.snp.makeConstraints {
            $0.leading.equalTo(playButton.snp.trailing).offset(20.adjusted)
            $0.bottom.equalTo(playButton.snp.bottom)
            $0.width.height.equalTo(24.adjusted)
        }
        forwardStateLabel.snp.makeConstraints {
            $0.leading.equalTo(forwardButton.snp.trailing).offset(8)
            $0.centerY.equalTo(forwardButton)
        }
        rewindButton.snp.makeConstraints {
            $0.trailing.equalTo(playButton.snp.leading).inset(-20.adjusted)
            $0.bottom.equalTo(playButton.snp.bottom)
            $0.width.height.equalTo(24.adjusted)
        }
        rewindStateLabel.snp.makeConstraints {
            $0.trailing.equalTo(rewindButton.snp.leading).inset(-8)
            $0.centerY.equalTo(rewindButton)
        }
    }
    
    let playButton = UIButton().then {
        $0.setImage(SDSIcon.icPlayCircleBlack.resized(to: .init(width: 48, height: 48)), for: .selected)
        $0.setImage(SDSIcon.icPauseCircleBlack.resized(to: .init(width: 48, height: 48)), for: .normal)
    }
    let rewindButton = UIButton().then {
        $0.setImage(SDSIcon.icFastRewindBlack, for: .normal)
        $0.setImage(SDSIcon.icFastRewindWhite, for: .selected)
    }
    let rewindStateLabel = UILabel().then {
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
    }
    let forwardButton = UIButton().then {
        $0.setImage(SDSIcon.icFastFowardBlack, for: .normal)
        $0.setImage(SDSIcon.icFastFowardWhite, for: .selected)
    }
    let forwardStateLabel = UILabel().then {
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
    }
    let startTimeLabel = UILabel().then {
        $0.font = SDSFont.body.font.withSize(12)
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    let videoSlider = VideoRangeSlider(frame: .init(origin: .zero,
                                                    size: .init(width: 268.adjusted,
                                                                height: 32.adjusted)))
    let endTimeLabel = UILabel().then {
        $0.font = SDSFont.body.font.withSize(12)
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    
}
