import UIKit
import SDSKit

class TermsVC: BaseAuthVC {
    var viewModel: TermsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setConfigView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setDefaultNextButton()
        self.changeNextButtonUi(data: false)
    }
    
    //MARK: - bind viewModel
    private func bindViewModel() {
        let output = self.viewModel?.termsTransform(from: .init(agreeAllButtonDidTap: self.agreeAllTermsButton.rx.tap.asObservable(),
                                                                temrs1ButtonDidTap: self.termsButton1,
                                                                temrs2ButtonDidTap: self.termsButton2,
                                                                temrs3ButtonDidTap: self.termsButton3,
                                                                nextButtonDidTap: self.nextButton.rx.tap.asObservable(),
                                                                backButtonDidTap: self.termsButton1.rx.tap.asObservable(),
                                                                didTermsConditionButtonTapped: self.termsAndConditionButton.rx.tap.asObservable()),
                                                    disposeBag: disposeBag)
        
        output?.termsAllSelected
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { data in
                self.agreeAllTermsButton.didButtonClicked(type: .selectAll, isSelected: data)
                self.changeNextButtonUi(data: data)
            })
            .disposed(by: disposeBag)
        
        output?.termsSelectedArray
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { data in
                self.changeButtonUi(data: data)
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - UI effect
    private func changeButtonUi(data: [Bool]) {
        DispatchQueue.main.async {
            var index: Int = 0
            if data.count > 0 {
                self.termsButtonList.forEach { button in
                    button.didButtonClicked(type: button.getButtonType(), isSelected: data[index])
                    index += 1
                }
            }
        }
    }
    
    private func changeNextButtonUi(data: Bool) {
        if data {
            self.nextButton.buttonState = .enabled
            self.nextButton.setTitle("auth_terms_button_title".localized(), for: .normal)
        } else {
            self.nextButton.buttonState = .disabled
            self.nextButton.setTitle("auth_terms_button_title".localized(), for: .normal)
        }
    }

    
    //MARK: - config View
    private func setConfigView() {
        self.view.addSubviews([stackView,
                               agreeAllTermsButton,
                               termsAndConditionButton])
        agreeAllTermsButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(48.adjusted)
        }
        agreeAllTermsButton.layer.cornerRadius = 24.adjusted
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(agreeAllTermsButton.snp.bottom).offset(ScreenUtils.setWidth(value: 24))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        termsButtonList = [termsButton1, termsButton2, termsButton3]
        stackView.addArrangeSubViews(termsButtonList)
        super.setTitleLabel(title: "auth_terms_title".localized())
        
        termsAndConditionButton.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).inset(ScreenUtils.setWidth(value: -20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 100))
        }
        self.navigationView.setTitle(title: "")
    }
    
    private func setDefaultNextButton() {
        self.nextButton.snp.remakeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(48.adjusted)
            nextButton.layer.cornerRadius = 24.adjusted
        }
    }
    
    //MARK: - Components
    private let stackView = UIStackView().then {
        $0.spacing = ScreenUtils.setWidth(value: 20)
        $0.axis = .vertical
        $0.distribution = .fill
    }
    private let agreeAllTermsButton = TermsButton(type: .selectAll, title: "auth_terms_all_agree_title".localized().setAttributeString(textColor: .PrimaryWhiteNormal,
                                                                                                                                       font: SDSFont.body2.font))
    private let termsButton1 = TermsButton(type: .selectOneByOne, title: "auth_terms_text1".localized().setAttributeString(textColor: .stepinWhite100,
                                                                                                                           font: SDSFont.callout.font))
    
    private let termsButton2 = TermsButton(type: .selectOneByOne, title: "auth_terms_text2".localized().setAttributeString(textColor: .stepinWhite100,
                                                                                                               font: SDSFont.callout.font))
    private let termsButton3 = TermsButton(type: .selectOneByOne, title: "auth_terms_text3".localized().setAttributeString(textColor: .stepinWhite100,
                                                                                                               font: SDSFont.callout.font))
    private var termsAndConditionButton = UIButton().then {
        let attributedString = NSMutableAttributedString(string: "auth_terms_and_condition_button_title".localized())
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.stepinWhite40, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: UIFont.suitRegularFont(ofSize: 12), range: NSRange(location: 0, length: attributedString.length))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    private var termsButtonList: [TermsButton] = []
}
