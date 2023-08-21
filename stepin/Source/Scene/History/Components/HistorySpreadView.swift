import UIKit
import SnapKit
import Then
import MarqueeLabel

class HistorySpreadView: UIView {

    init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setData(time: Date,
                          musicName: String,
                          singerName: String) {

        let timeString = time.toString(dateFormat: "HH:mm")
        self.timeLabel.text = timeString
        self.musicNameLabel.text = musicName
        self.singerNameLabel.text = singerName
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinWhite20
        self.addSubviews([timeLabel, musicNameLabel, singerNameLabel])
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 15))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 7))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        musicNameLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 4))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 7))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        singerNameLabel.snp.makeConstraints {
            $0.top.equalTo(musicNameLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 4))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 7))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
    }
    
    private var timeLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite40
    }

    private var musicNameLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
    }
    private var singerNameLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
    }
}

