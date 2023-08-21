import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Lottie

class EnterIdVC: BaseAuthVC {
    var viewModel: EnterIdViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
        setCompleteClosre()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textView.textField.becomeFirstResponder()
        }
    }
    
    //MARK: - view model binding
    private func bindViewModel() {
        let output = self.viewModel?.getIdTransform(from: .init(textField: self.textView.textField,
                                                                nextButtonDidTap: self.nextButton.rx.tap.asObservable()),
                                                    disposeBag: disposeBag)
        output?.isTextFieldClear
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                if state {
                    vc.textView.setBottomText(title: "auth_id_default_noti".localized(), color: .PrimaryWhiteAlternative)
                } 
            })
            .disposed(by: disposeBag)
        
        output?.currentIDState
            .asDriver()
            .drive(onNext: { [weak self] state in
                self?.lottieIndicator.stop()
                self?.lottieIndicator.isHidden = true
                if state == .unformatted_dupplicated_id {
                    self?.nextButton.buttonState = .disabled
                    self?.nextButton.setTitle("auth_id_button_title".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .stepinRed100)
                    self?.textView.setBottomText(title: "auth_id_contain_already_use_noti".localized(), color: .stepinRed100)
                }
            })
            .disposed(by: disposeBag)
        output?.indicatorStatus
            .withUnretained(self)
            .asDriver(onErrorJustReturn: (EnterIdVC(), false))
            .drive(onNext: { vc, status in
                DispatchQueue.main.async {
                    if status {
                        vc.lottieIndicator.isHidden = false
                        vc.lottieIndicator.play()
                    } else {
                        vc.lottieIndicator.isHidden = true
                        vc.lottieIndicator.stop()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.toastMessage
            .withUnretained(self)
            .asDriver(onErrorJustReturn: (EnterIdVC(),""))
            .drive(onNext: { (vc, value) in
                vc.view?.makeToast(title: value, type: .redX)
            })
            .disposed(by: disposeBag)
            
    }
    
    
    //MARK: - view config
    private func setCompleteClosre() {
        self.textView.didCompleteCondition = { state in
            self.viewModel?.isComplete = state
            if state {
                self.nextButton.buttonState = .enabled
                self.nextButton.setTitle("auth_id_button_title".localized(), for: .normal)
            } else {
                self.nextButton.buttonState = .disabled
                self.nextButton.setTitle("auth_id_button_title".localized(), for: .normal)
            }
        }
        
    }
    
    private func setLayout() {
        self.view.addSubview(textView)
        self.view.addSubview(lottieIndicator)
        
        lottieIndicator.snp.makeConstraints {
            $0.height.width.equalTo(200) // 프로그래스바 크기 얼마로 해야할까요?
            $0.center.equalTo(self.view)
        }
        lottieIndicator.isHidden = true
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        textView.setPlaceHolder(text: "auth_id_placeholder".localized())
        textView.setBottomText(title: "auth_id_default_noti".localized(), color: .stepinWhite40)
        self.navigationView.setTitle(title: "auth_email_Verify_navigation_title".localized())
        super.setTitleLabel(title: "auth_id_title".localized())
        super.setNextButtonTitle(title: "auth_id_button_title".localized())
    }
    private var textView = AuthTextFieldView(type: .id)
    private var lottieIndicator = LottieAnimationView(name: "loading").then {
        $0.loopMode = .loop
    }
}
