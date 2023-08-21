import Foundation
import UIKit
import SDSKit
import SnapKit
import Then

class HistoryNavigationView: UIView {
    var heartButtonCompletion: ((Bool) -> Void)?
    var titleButtonCompletion: (() -> Void)?
    
    private var selectionState: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        setLayout()
        addTargetButton()
    }
    
    internal func setSelectionState(state: Bool) {
        self.selectionState = state
    }
    
    internal func getSelectionState() -> Bool {
        return self.selectionState
    }
    
    internal func setTitle(date: String) {
        self.titleButton.setTitle(date, for: .normal)
    }
    
    private func addTargetButton() {
        self.heartButton.addTarget(self,
                                    action: #selector(didHeartButtonTapped),
                                    for: .touchUpInside)
        self.titleButton.addTarget(self,
                                   action: #selector(didTitleButtonTapped),
                                   for: .touchUpInside)
    }
    
    @objc private func didHeartButtonTapped() {
//        guard let completion = heartButtonCompletion else {return}
//        completion(self.heartButton.isSelected)
        heartButton.isSelected.toggle()
        setHeartButtonBorder()
    }
    
    @objc private func didTitleButtonTapped() {
        guard let completion = titleButtonCompletion else {return}
        completion()
    }
    
    private func setHeartButtonBorder() {
        self.heartButton.layer.cornerRadius = 16.adjusted
        self.heartButton.layer.borderWidth = 1
        self.heartButton.clipsToBounds = true
        if self.heartButton.isSelected {
            self.heartButton.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        } else {
            self.heartButton.layer.borderColor = UIColor.PrimaryWhiteAlternative.cgColor
        }
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.addSubviews([titleButton, leftButton, rightButton, heartButton])
        titleButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
        leftButton.snp.makeConstraints {
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
            $0.top.bottom.equalTo(titleButton)
            $0.trailing.equalTo(titleButton.snp.leading).offset(-8)
        }
        
        rightButton.snp.makeConstraints {
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
            $0.top.bottom.equalTo(titleButton)
            $0.leading.equalTo(titleButton.snp.trailing).offset(8)
        }
        
        heartButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8.adjusted)
            $0.width.height.equalTo(32.adjusted)
        }
        setHeartButtonBorder()
    }
    
    internal var titleButton = UIButton().then {
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 20)
    }
    
    var leftButton = UIButton().then {
        $0.setImage(ImageLiterals.icWhiteArrow, for: .normal)
    }
    var rightButton = UIButton().then {
        $0.setImage(ImageLiterals.icRightArrow, for: .normal)
    }
    
    internal var heartButton = UIButton().then {
        $0.setImage(SDSIcon.icHeartUnfill, for: .normal)
        $0.setBackgroundColor(.PrimaryWhiteDisabled, for: .selected)
        $0.setImage(SDSIcon.icHeartFill, for: .selected)
        $0.setBackgroundColor(.PrimaryWhiteNormal, for: .selected)
    }
}
