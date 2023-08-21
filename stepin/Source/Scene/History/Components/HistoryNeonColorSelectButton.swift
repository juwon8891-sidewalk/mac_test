import UIKit
import Then
import SnapKit
import RxSwift
import RxRelay
import SDSKit

class HistoryNeonColorSelectButton: UIView {
    private var selectedColor: UIColor = .white
    private var beforeSelectedColor: UIColor = .white
    var selectedNeonColorCompletion: ((UIColor) -> Void)?

    private var viewModel = NeonColorSelectButtonViewModel()
    private var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setDefaultButtonLayout()
        self.setAnimatingLayout()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let output = self.viewModel.transform(from: .init(defualtButton: self.defaultButton,
                                                          selectButton1: self.selectButton1,
                                                          selectButton2: self.selectButton2,
                                                          selectButton3: self.selectButton3,
                                                          selectButton4: self.selectButton4,
                                                          selectButton5: self.selectButton5,
                                                          selectButton6: self.selectButton6),
                                              disposeBag: disposeBag)
        
        output.didSelecteViewhidden
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: (self, true))
            .drive(onNext: { (vc, state) in
                if state {
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        self.animatingBackgroundView.alpha = 0
                        self.defaultButtonBackground.alpha = 1
                    } completion: { _ in
                        self.animatingBackgroundView.isHidden = true
                    }
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        self.animatingBackgroundView.isHidden = false
                        self.animatingBackgroundView.alpha = 1
                        self.defaultButtonBackground.alpha = 0
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedColor
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { (vc, color) in
                self.defaultButton.backgroundColor = color
                if color == .clear {
                    self.defaultButton.setImage(SDSIcon.icClearNeonColor, for: .normal)
                } else {
                    self.defaultButton.setImage(nil, for: .normal)
                }
                guard let completion = self.selectedNeonColorCompletion else {return}
                completion(self.getSelectedColor())
            })
            .disposed(by: disposeBag)
    }
    
    internal func getSelectedColor() -> UIColor {
        return self.defaultButton.backgroundColor!
    }
    
    private func setAnimatingLayout() {
        self.addSubview(animatingBackgroundView)
        animatingBackgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        animatingBackgroundView.layer.cornerRadius = 25.adjusted
        animatingBackgroundView.clipsToBounds = true
        
        self.animatingBackgroundView.addArrangeSubViews([selectButton1, selectButton2, selectButton3, selectButton4, selectButton5])
        self.animatingBackgroundView.isHidden = true
        self.animatingBackgroundView.alpha = 0
    }
    
    //최초 로딩시 뷰
    private func setDefaultButtonLayout() {
        self.addSubview(defaultButtonBackground)
        defaultButtonBackground.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        defaultButtonBackground.clipsToBounds = true
        defaultButtonBackground.layer.cornerRadius = 24

        self.defaultButtonBackground.addSubview(defaultButton)
        defaultButton.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(24)
        }
        defaultButton.layer.borderColor = UIColor.white.cgColor
        defaultButton.layer.borderWidth = 1

        defaultButton.clipsToBounds = true
        defaultButton.layer.cornerRadius = 12
    }
    
    
    //Default
    private var defaultButtonBackground = UIView().then {
        $0.backgroundColor = .PrimaryBlackAlternative
    }
    internal var defaultButton = UIButton().then {
        $0.backgroundColor = .white
    }
    
    //animatingView
    private var animatingBackgroundView = UIStackView(frame: .init(origin: .zero,
                                                                   size: .init(width: 48,
                                                                               height: 216))).then {
        $0.backgroundColor = .PrimaryBlackAlternative
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 20
        $0.layoutMargins = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private var selectButton1 = UIButton(frame: .init(origin: .zero, size: .init(width: 22,
                                                                                 height: 22))).then {
        $0.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.clipsToBounds = true
    }
    private var selectButton2 = UIButton(frame: .init(origin: .zero, size: .init(width: 22,
                                                                                 height: 22))).then {
        $0.backgroundColor = UIColor(red: 255.0 / 255.0, green: 199.0 / 255.0, blue: 1.0 / 255.0, alpha: 1.0)
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.clipsToBounds = true
    }
    private var selectButton3 = UIButton(frame: .init(origin: .zero, size: .init(width: 22,
                                                                                 height: 22))).then {
        $0.backgroundColor = UIColor(red: 85.0 / 255.0, green: 239.0 / 255.0, blue: 174.0 / 255.0, alpha: 1.0)
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.clipsToBounds = true
    }
    private var selectButton4 = UIButton(frame: .init(origin: .zero, size: .init(width: 22,
                                                                                 height: 22))).then {
        $0.backgroundColor = UIColor(red: 255.0 / 255.0, green: 49.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.clipsToBounds = true
    }
    private var selectButton5 = UIButton(frame: .init(origin: .zero, size: .init(width: 22,
                                                                                 height: 22))).then {
        $0.backgroundColor = UIColor(red: 81.0 / 255.0, green: 0.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.clipsToBounds = true
    }
    //삭제 필요
    private var selectButton6 = UIButton(frame: .init(origin: .zero, size: .init(width: 24.adjusted,
                                                                                 height: 24.adjusted))).then {
        $0.backgroundColor = .SecondaryGreenNormal
        $0.layer.cornerRadius = 12.adjusted
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.clipsToBounds = true
    }
}
