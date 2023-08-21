import UIKit
import SDSKit
import SnapKit
import Then

class HistoryCVC: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(imagePath: String,
                  score: Float,
                  isChecked: Bool,
                  isCheckedMode: Bool,
                  isHighlithedMode: Bool) {
        let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = doucumentDirectory.appendingPathComponent("\(imagePath)")
        self.thumbnailImageView.image = ABVideoHelper.thumbnailFromVideo(videoUrl: videoURL, time: .zero)
        
        let stateText = "\(score)".scoreToState(score: score)
        let stateColor = "\(score)".scoreToColor(score: score)
        self.scoreStateLabel.setTextWithShadow(stateText,
                                               color: stateColor,
                                               radius: 5)
        self.selectButton.isSelected = isChecked
        
        if isCheckedMode {
            self.selectButton.isHidden = false
        } else {
            self.selectButton.isHidden = true
        }
        
        if isHighlithedMode {
            self.highLightButton.isHidden = false
        } else {
            self.highLightButton.isHidden = true
        }
        
        setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([thumbnailImageView, scoreStateLabel, selectButton, highLightButton])
        
        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        thumbnailImageView.layer.cornerRadius = 4.adjusted
        thumbnailImageView.clipsToBounds = true
        
        scoreStateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(12.adjusted)
            $0.centerX.equalToSuperview()
        }
        
        selectButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8.adjusted)
            $0.width.height.equalTo(16.adjusted)
        }
        
        highLightButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8.adjusted)
            $0.width.height.equalTo(16.adjusted)
        }
    }
    
    private let scoreStateLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
    
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let highLightButton = UIButton().then {
        $0.setImage(SDSIcon.icHeartFill, for: .normal)
    }
    
    private let selectButton = UIButton().then {
        $0.setImage(SDSIcon.icRadioDeselect, for: .normal)
        $0.setImage(SDSIcon.icRadioCheck, for: .selected)
    }
}
