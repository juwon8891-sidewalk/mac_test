import UIKit
import SDSKit
import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

enum AuthViewType {
    case login
    case emailLogin
    case findPassword
    case resetPassword
    case terms
    case verifyEmail
    case setPassword
    case setBirthDate
    case setUserID
}

class BaseAuthVC: UIViewController {
    internal var viewType: AuthViewType?
    var disposeBag = DisposeBag()
        
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = .stepinBlack100
        self.setBaseLayout()
        self.didBackButtonTapped()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.initNotificationCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deInitNotificationCenter()
    }
    
    private func didBackButtonTapped() {
        self.navigationView.backButtonCompletion = {
            HapticService.shared.playFeedback()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func initNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func deInitNotificationCenter() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc internal func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let yTransition = -keyboardFrame.cgRectValue.height + ScreenUtils.setWidth(value: 23)
            self.nextButton.transform = CGAffineTransform(translationX: 0, y: yTransition)
        }
        
    }
    
    @objc internal func keyboardWillHide(_ notification: Notification) {
        if notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] is NSValue {
            self.nextButton.transform = .identity
        }

    }
    
    internal func setBaseLayout() {
        self.view.addSubviews([navigationView, titleLabel, subTitleLabel, nextButton])
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 7))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(ScreenUtils.setWidth(value: 26))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 4))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 18))
            $0.height.equalTo(ScreenUtils.setWidth(value: 17))
        }
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(48.adjusted)
            nextButton.layer.cornerRadius = 24.adjusted
        }
    }
    
    /**
     상단 titleLabel 값 설정
     */
    internal func setTitleLabel(title: String,
                                     subTitle: String = "") {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    }
    
    func setNextButtonTitle(title: String) {
        self.nextButton.setTitle(title, for: .normal)
    }
    
    var navigationView = TitleNavigationView()
    var titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = SDSFont.h1.font
        $0.textColor = .stepinWhite100
    }
    var subTitleLabel = UILabel().then {
        $0.font = SDSFont.callout.font
        $0.textColor = .stepinWhite40
    }
    
    var nextButton = SDSLargeButton(type: .disabled).then {
        $0.setTitle("auth_email_login_login_button_title".localized(), for: .normal)
    }
}
