import Foundation
import SDSKit
import UIKit
import SnapKit
import Then

class ProfileInfoButton: UIView {
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func bindText(category: String,
                  count: Int?) {
        self.categoryLabel.text = category
        if let count = count {
            self.countLabel.text = formatNumber(count)
        } else {
            self.countLabel.text = " "
        }
    }
    
    func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if number >= 1000 {
            let numberInK = Double(number) / 1000.0
            formatter.positiveSuffix = "k"
            return formatter.string(from: NSNumber(value: numberInK)) ?? ""
        } else {
            return formatter.string(from: NSNumber(value: number)) ?? ""
        }
    }
    
    private func setLayout() {
        self.addSubviews([countLabel, categoryLabel])
        countLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(8)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private let countLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = SDSFont.caption1.font
        $0.textColor = .PrimaryWhiteNormal
    }
    
    private let categoryLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
    }
}
