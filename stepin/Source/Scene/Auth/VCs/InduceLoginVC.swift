import UIKit
import SDSKit
import RxSwift
import RxCocoa

class InduceLoginVC: UIViewController {
    var viewModel: InduceLoginViewModel?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppear:  self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      signUpButtonTapped: self.signUpButton.rx.tap.asObservable()),
                                          disposeBag: disposeBag)
        
        output?.iconImageData
            .withUnretained(self)
            .bind(onNext: { (vc, image) in
                self.iconImageView.image = image
            })
            .disposed(by: disposeBag)
        
        output?.titleData
            .withUnretained(self)
            .bind(onNext: { (vc, title) in
                self.titleLabel.text = title
            })
            .disposed(by: disposeBag)
    }
    
    private func setLayout() {
        self.view.addSubviews([iconImageView, titleLabel, signUpButton])
        iconImageView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 170))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 84))
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.iconImageView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview()
        }
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
    }
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
    private let signUpButton = UIButton().then {
        $0.backgroundColor = .SystemBlue
        $0.setTitle("induce_login_signup_button_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 20)
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 8)
    }

}
