import UIKit
import SDSKit
import SnapKit
import Then

class GeneralAuthTextView: UIView {
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setLayout()

    }
    
    
    
    private func setLayout() {
        self.addSubviews([bottomLine, bottomText, initView])
        initView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 18))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(initView.snp.bottom).offset(ScreenUtils.setWidth(value: 4))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(1)
        }
        bottomText.snp.makeConstraints {
            $0.top.equalTo(bottomLine.snp.bottom).offset(ScreenUtils.setWidth(value: 8))
            $0.leading.equalTo(bottomLine.snp.leading)
            $0.trailing.equalTo(bottomLine.snp.trailing)
        }
    }
    
    internal var initView = UIView()
    internal var bottomLine = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
    internal var bottomText = UILabel().then {
        $0.textColor = .SystemBlue
        $0.font = .suitRegularFont(ofSize: 12)
        $0.numberOfLines = 0
    }
}
