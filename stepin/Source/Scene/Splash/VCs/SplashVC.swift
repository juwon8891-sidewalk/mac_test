import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import SDSKit

class SplashVC: UIViewController {
    var viewModel: SplashViewModel?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(alertView: self.updateAlertView),
                                          disposeBag: disposeBag)
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([backgroundImageView,
                               logoImageView,
                               logoNameImageView,
                               updateAlertView])
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(200.adjusted)
        }
        
        logoNameImageView.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(40.adjusted)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(90.adjusted)
            $0.height.equalTo(20.adjusted)
        }
        
        updateAlertView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        updateAlertView.setCancelButtonTitle(title: "splash_new_version_quit_button_title".localized())
        updateAlertView.setOkButtonTitle(title: "splash_new_version_link_button_title".localized())
        updateAlertView.isHidden = true
    }
    
    private let backgroundImageView = UIImageView(image: ImageLiterals.splashBackground)
    private var logoImageView = UIImageView(image: SDSIcon.icStepinImageLogo)
    private var logoNameImageView = UIImageView(image: SDSIcon.icStepinTextLogo)
    private var updateAlertView = SDSAlertView(size: CGSize(width: 272.adjusted,
                                                            height: 193.adjusted),
                                               icon: nil,
                                               iconPath: nil,
                                               title: "splash_new_version_released_title".localized(),
                                               titleColor: .PrimaryWhiteNormal,
                                               description: "splash_new_version_released_description".localized(),
                                               descriptionColor: .PrimaryWhiteNormal)
}
