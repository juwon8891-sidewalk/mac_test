import UIKit

class ReportButton: UIButton {
    var buttonTapCompletion: ((String) -> Void)?
    
    init(title: String, isBottomGradientHidden: Bool) {
        super.init(frame: .zero)
        self.backgroundColor = .stepinBlack100
        var config = UIButton.Configuration.plain()
        config.attributedTitle = title.setAttributeString(textColor: .stepinWhite100,
                                                          font: .suitMediumFont(ofSize: 16))
        self.configuration = config
        
        let bottomGradientView = HorizontalGradientView()
        self.addSubview(bottomGradientView)
        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        bottomGradientView.isHidden = isBottomGradientHidden
        self.setTargetButton()
    }
    
    private func setTargetButton() {
        self.addTarget(self, action: #selector(didReportButtonTapped), for: .touchUpInside)
    }
    
    @objc private func didReportButtonTapped() {
        guard let completion = buttonTapCompletion else {return}
        completion(self.titleLabel?.text ?? "")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
