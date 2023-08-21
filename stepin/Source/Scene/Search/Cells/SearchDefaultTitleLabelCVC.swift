import UIKit
import SDSKit
import SnapKit
import Then

class SearchDefaultTitleLabelCVC: UICollectionViewCell {
    static let identifier: String = "SearchDefaultTitleLabelCVC"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setData(title: String) {
        self.titleLabel.text = title
        self.setLayout()
    }
    
    internal func changeTextColor(targetText: String) {
        let text: String = self.titleLabel.text ?? ""
        let attributeString = NSMutableAttributedString(string: text)
        var textFirstIndex: Int = 0
        if let textFirstRange = text.range(of: "\(targetText)", options: .caseInsensitive) {
            textFirstIndex = text.distance(from: text.startIndex, to: textFirstRange.lowerBound) // 거리(인덱스) 구해서 저장.
            attributeString.addAttribute(.foregroundColor, value: UIColor.SystemBlue, range: NSRange(location: textFirstIndex, length: targetText.count))
            self.titleLabel.attributedText = attributeString
        }
    }
    
    private func setLayout() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .left
    }
    
}
