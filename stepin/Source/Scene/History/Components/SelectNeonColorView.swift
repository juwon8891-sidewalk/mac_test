import UIKit
import SnapKit
import Then

class SelectNeonColorView: UIView {
    
    var selectedColorCompletion: ((CIColor) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack50
        self.addSubviews([buttonBackgroundButton, stackView])
        stackView.addArrangeSubViews([whiteColorButton, blackColorButton, pinkColorButton, blueColorButton, purpleColorButton])
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            $0.centerY.equalToSuperview()
        }
        buttonBackgroundButton.snp.makeConstraints {
            $0.center.equalTo(self.whiteColorButton)
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        buttonBackgroundButton.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        buttonBackgroundButton.clipsToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setButtonRadius()
    }
    
    @objc private func didButtonTapped(_ button: UIButton) {
        self.backGroundViewMoved(button: button)
        guard let completion = self.selectedColorCompletion else {return}
        if let selectedColor = button.backgroundColor {
            completion(self.colorToRGB(uiColor: selectedColor))
        }
    }
    
    func colorToRGB(uiColor: UIColor) -> CIColor
    {
        return CIColor(color: uiColor)
    }
    
    private func backGroundViewMoved(button: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.buttonBackgroundButton.center = CGPoint(x: button.center.x,
                                                         y: self.stackView.center.y)
        }
    }
    
    internal func setButtonRadius() {
        self.whiteColorButton.layer.cornerRadius = whiteColorButton.frame.width / 2
        self.blackColorButton.layer.cornerRadius = blackColorButton.frame.width / 2
        self.pinkColorButton.layer.cornerRadius = pinkColorButton.frame.width / 2
        self.blueColorButton.layer.cornerRadius = blueColorButton.frame.width / 2
        self.purpleColorButton.layer.cornerRadius = purpleColorButton.frame.width / 2
    }
    
    private lazy var whiteColorButton = UIButton(frame: .init(origin: .zero,
                                                         size: .init(width: ScreenUtils.setWidth(value: 20),
                                                                     height: ScreenUtils.setWidth(value: 20)))).then {
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .stepinWhite100
        $0.addTarget(self,
                     action: #selector(didButtonTapped(_:)),
                     for: .touchUpInside)
    }
    private lazy var blackColorButton = UIButton(frame: .init(origin: .zero,
                                                         size: .init(width: ScreenUtils.setWidth(value: 20),
                                                                     height: ScreenUtils.setWidth(value: 20)))).then {
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .stepinYellow
        $0.addTarget(self,
                     action: #selector(didButtonTapped(_:)),
                     for: .touchUpInside)
    }
    
    private lazy var pinkColorButton = UIButton(frame: .init(origin: .zero,
                                                         size: .init(width: ScreenUtils.setWidth(value: 20),
                                                                     height: ScreenUtils.setWidth(value: 20)))).then {
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .stepinPink
        $0.addTarget(self,
                     action: #selector(didButtonTapped(_:)),
                     for: .touchUpInside)
    }
  
    private lazy var blueColorButton = UIButton(frame: .init(origin: .zero,
                                                         size: .init(width: ScreenUtils.setWidth(value: 20),
                                                                     height: ScreenUtils.setWidth(value: 20)))).then {
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .stepinBlue
        $0.addTarget(self,
                     action: #selector(didButtonTapped(_:)),
                     for: .touchUpInside)
    }
    
    private lazy var purpleColorButton = UIButton(frame: .init(origin: .zero,
                                                         size: .init(width: ScreenUtils.setWidth(value: 20),
                                                                     height: ScreenUtils.setWidth(value: 20)))).then {
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .stepinPurple
        $0.addTarget(self,
                     action: #selector(didButtonTapped(_:)),
                     for: .touchUpInside)
    }
    
    private var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = ScreenUtils.setWidth(value: 20)
        $0.layoutMargins = UIEdgeInsets(top: .zero, left: 12, bottom: .zero, right: 12)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private var buttonBackgroundButton = UIImageView(image: ImageLiterals.icNeonColorSelectedBackground)
    
}
