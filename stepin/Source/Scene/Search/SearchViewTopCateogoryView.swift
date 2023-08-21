import UIKit
import SnapKit
import Then

class SearchViewTopCategoryView: UIView {
    private var buttonArr: [UIButton] = []
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.scrollView.delegate = self
        self.setLayout()
        self.addButtonTarget()
    }
    
    private func addButtonTarget() {
        self.hotButton.addTarget(self,
                                 action: #selector(didButtonTapped(_:)), for: .touchUpInside)
        self.accountButton.addTarget(self,
                                 action: #selector(didButtonTapped(_:)), for: .touchUpInside)
        self.danceButton.addTarget(self,
                                 action: #selector(didButtonTapped(_:)), for: .touchUpInside)
        self.hashtagButton.addTarget(self,
                                 action: #selector(didButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func didButtonTapped(_ sender: UIButton) {
        for button in buttonArr {
            if button != sender {
                button.isSelected = false
                button.titleLabel?.font = .suitMediumFont(ofSize: 16)
            } else {
                button.titleLabel?.font = .suitExtraBoldFont(ofSize: 20)
                button.isSelected = true
            }
        }
    }
    
    private func setLayout() {
        self.buttonArr = [hotButton, accountButton, danceButton, hashtagButton]
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        scrollView.addSubviews(self.buttonArr)
        hotButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 41))
        }
        self.hotButton.isSelected = true
        self.hotButton.titleLabel?.font = .suitExtraBoldFont(ofSize: 20)
        accountButton.snp.makeConstraints {
            $0.leading.equalTo(self.hotButton.snp.trailing).offset(ScreenUtils.setWidth(value: 40))
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 85))
        }
        danceButton.snp.makeConstraints {
            $0.leading.equalTo(self.accountButton.snp.trailing).offset(ScreenUtils.setWidth(value: 40))
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 64))
        }
        hashtagButton.snp.makeConstraints {
            $0.leading.equalTo(self.danceButton.snp.trailing).offset(ScreenUtils.setWidth(value: 40))
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 95))
            $0.trailing.equalToSuperview()
        }
    }

    private var scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isDirectionalLockEnabled = true
        $0.isPagingEnabled = true
    }
    internal var hotButton = UIButton().then {
        $0.setTitle("searchView_hot_tab_title".localized(), for: .normal)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.setTitleColor(.stepinWhite40, for: .normal)
    }
    internal var accountButton = UIButton().then {
        $0.setTitle("searchView_Account_tab_title".localized(), for: .normal)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.setTitleColor(.stepinWhite40, for: .normal)
    }
    internal var danceButton = UIButton().then {
        $0.setTitle("searchView_Dance_tab_title".localized(), for: .normal)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.setTitleColor(.stepinWhite40, for: .normal)
    }
    internal var hashtagButton = UIButton().then {
        $0.setTitle("searchView_hashtags_tab_title".localized(), for: .normal)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.setTitleColor(.stepinWhite40, for: .normal)
    }
        
}

extension SearchViewTopCategoryView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0{
            scrollView.contentOffset.y = 0
        }
    }
}
