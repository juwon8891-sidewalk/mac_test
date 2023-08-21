import UIKit
import SnapKit
import Then
import Foundation

class NavigationView: UIView {
    var backButtonCompletion: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        self.viewConfig()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func viewConfig() {
        self.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(48.adjusted)
        }
        backButton.addTarget(self, action: #selector(didBackButtonClicked(_:)), for: .touchUpInside)
    }
    
    internal func setBackbuttonHidden() {
        self.backButton.isHidden = true
    }
    
    internal func setBackbuttonShow() {
        self.backButton.isHidden = false
    }
    
    @objc private func didBackButtonClicked(_ sender: UIButton) {
        guard let completion = backButtonCompletion else {return}
        completion()
    }
    
    internal var backButton = UIButton().then {
        $0.setImage(ImageLiterals.icWhiteArrow, for: .normal)
    }
}
