import UIKit
import SnapKit
import Then

class SSFTopNavigationView: UIView {
    var didBackButtonTappedCompletion: (() -> Void)?
    var didSearchButtonTappedCompletion: (() -> Void)?
    init() {
        super.init(frame: .zero)
        setLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setTitle(title: String) {
        self.musicTitleLabel.text = title
    }
    

    private func setLayout() {
        self.addSubviews([backButton, musicTitleLabel, searchButton])
        musicTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(backButton).offset(ScreenUtils.setWidth(value: 16))
            $0.trailing.equalTo(searchButton).inset(ScreenUtils.setWidth(value: 16))
        }
        
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
    }
    @objc private func didBackButtonTapped() {
        guard let completion = didBackButtonTappedCompletion else {return}
        completion()
    }
    
    @objc private func didSearchButtonTapped() {
        guard let completion = didSearchButtonTappedCompletion else {return}
        completion()
    }
    
    internal lazy var backButton = UIButton().then {
        $0.addTarget(self,
                     action: #selector(didBackButtonTapped),
                     for: .touchUpInside)
        $0.setBackgroundImage(ImageLiterals.icWhiteArrow, for: .normal)
    }
    
    internal lazy var searchButton = UIButton().then {
        $0.addTarget(self,
                     action: #selector(didSearchButtonTapped),
                     for: .touchUpInside)
        $0.setBackgroundImage(ImageLiterals.icSearch, for: .normal)
    }
    
    private var musicTitleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
}
