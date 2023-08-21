import UIKit
import Then
import SnapKit
import Kingfisher

class HistoryTVC: UITableViewCell {
    var spreadButtonTappedCompletion: (() -> Void)?
    static let identifier: String = "HistoryTVC"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setButtonTarget()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImageView.image = nil
        self.descriptionView.setData(time: Date(), musicName: "", singerName: "")
        self.spreadOutButton.setTitle("", for: .normal)
        self.checkButton.isHidden = true
    }
    
    internal func setData(videoPath: String,
                          score: Float,
                          isSelected: Bool,
                          time: Date,
                          musicName: String,
                          singerName: String,
                          row: Int) {
        let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = doucumentDirectory.appendingPathComponent("\(videoPath)")
        self.thumbnailImageView.image = ABVideoHelper.thumbnailFromVideo(videoUrl: videoURL, time: .zero)
        self.spreadOutButton.setTitle(self.getScoreState(score: score), for: .normal)
        self.checkButton.isSelected = isSelected
        self.descriptionView.setData(time: time,
                                     musicName: musicName,
                                     singerName: singerName)
        setLayout()
    }
    
    private func setButtonTarget() {
        self.spreadOutButton.addTarget(self,
                                       action: #selector(didSpreadOutButtonTapped),
                                       for: .touchUpInside)
    }
    @objc private func didSpreadOutButtonTapped() {
        self.animateSpreadOutButton()
        self.spreadOutButton.isSelected = !self.spreadOutButton.isSelected
    }
    
    internal func resetDescriptionViewLayout() {
        self.descriptionView.transform = .identity
    }
    
    internal func animateSpreadOutButton() {
        guard let completion = spreadButtonTappedCompletion else {return}
        if self.spreadOutButton.isSelected {
            UIView.animate(withDuration: 0.01,
                           delay: 0) {
                self.backgroundShadowView.drawShadow(color: .stepinBlack100, opacity: 0, offset: CGSize(width: 0, height: 0), radius: ScreenUtils.setWidth(value: 0))
                self.descriptionView.transform = .identity
            } completion: { _ in
                completion()
            }
        } else {
            UIView.animate(withDuration: 0.01,
                           delay: 0) {
                self.backgroundShadowView.layer.borderColor = UIColor.clear.cgColor
                self.backgroundShadowView.layer.borderWidth = 1
                self.backgroundShadowView.drawShadow(color: .stepinBlack100, opacity: 0.8, offset: CGSize(width: 0, height: 10), radius: ScreenUtils.setWidth(value: 5))
                self.descriptionView.transform = CGAffineTransform(translationX: 0, y: ScreenUtils.setWidth(value: 80))
            } completion: { _ in
                completion()
            }
        }
    }
    
    internal func setSpreadOutButtonSelected(state: Bool) {
        self.spreadOutButton.isSelected = state
    }
    
    internal func setCellButtonHiddenState(state: Bool) {
        self.checkButton.isHidden = state
    }
    
    internal func setCellCheckedState(state: Bool) {
        self.checkButton.isSelected = state
        self.isSelected = state
    }
    
    private func getScoreState(score: Float) -> String {
        switch score {
        case 90.0 ... 100.0:
            return "history_view_score_text_perfect".localized()
        case 70.0 ... 90.0:
            return "history_view_score_text_great".localized()
        case 40.0 ... 70.0:
            return "history_view_score_text_good".localized()
        default:
            return "history_view_score_text_bad".localized()
        }
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.selectionStyle = .none
        self.contentView.addSubviews([descriptionView, backgroundShadowView, spreadOutButton, checkButton])
        descriptionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 80))
            $0.bottom.equalTo(backgroundShadowView.snp.bottom)
        }
        descriptionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        descriptionView.layer.cornerRadius = ScreenUtils.setWidth(value: 4)
        descriptionView.clipsToBounds = true
        
        backgroundShadowView.addSubview(thumbnailImageView)
        backgroundShadowView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 3))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 147))
        }
        backgroundShadowView.layer.cornerRadius = ScreenUtils.setWidth(value: 4)
        backgroundShadowView.clipsToBounds = false
        
        thumbnailImageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        thumbnailImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 4)
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        
        spreadOutButton.snp.makeConstraints {
            $0.bottom.equalTo(self.backgroundShadowView
                .snp.bottom).inset(ScreenUtils.setWidth(value: 8))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 33))
            $0.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        
        checkButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 12))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 16))
        }
        checkButton.isHidden = true
    }
    private var backgroundShadowView = UIView()
    private var thumbnailImageView = UIImageView()
    internal var spreadOutButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("", for: .normal)
        $0.titleLabel?.font = .suitRegularFont(ofSize: 14)
        $0.setImage(ImageLiterals.icBottomArrow, for: .normal)
        $0.setImage(ImageLiterals.icTopArrow, for: .selected)
    }
    private var checkButton = UIButton().then {
        $0.setImage(ImageLiterals.icSelected, for: .selected)
        $0.setImage(ImageLiterals.icUnselect, for: .normal)
    }
    private var descriptionView = HistorySpreadView()
}
