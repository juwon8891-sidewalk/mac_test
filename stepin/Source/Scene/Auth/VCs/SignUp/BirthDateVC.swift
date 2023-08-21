import UIKit
import SDSKit
import SnapKit
import Then
import RxCocoa
import RxSwift

class BirthDateVC: BaseAuthVC {
    var viewModel: BirthDateViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
        setBottomLineText()
    }
    
    //MARK: - bind View model
    private func bindViewModel() {
        let output = self.viewModel?.getBirthdayTransform(from: .init(datePickerSelected: datepicker.rx.date.asObservable(),
                                                                      nextButtonDidTap: self.nextButton.rx.tap.asObservable()),
                                                          disposeBag: self.disposeBag)
        
        output?.selectedDate
            .asDriver()
            .drive(onNext: { [weak self] str in
                self?.textView.setDateLabel(date: str)
                if str == "auth_birthDate_placeholder".localized() {
                    self?.textView.setPlaceHolderColor()
                } else {
                    self?.textView.setLabelColor()
                }
            })
            .disposed(by: disposeBag)
        
        output?.ageRestrictionInfo
            .asDriver()
            .drive(onNext: { [weak self] bool in
                if bool {
                    self?.textView.setBottomLineColor(color: .stepinWhite100)
                    self?.textView.setBottomText(title: "", color: .stepinWhite100)
                } else{
                    self?.textView.setBottomLineColor(color: .stepinRed100)
                    if Locale.current.region == "KR" {
                        self?.textView.setBottomText(title: "auth_birthDate_age_noti_kr".localized(), color: .SystemRed)
                    } else {
                        self?.textView.setBottomText(title: "auth_birthDate_age_noti".localized(), color: .SystemRed)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.selectedComplete
            .asDriver()
            .drive(onNext: { [weak self] bool in
                if bool {
                    self?.textView.setBottomLineColor(color: .SystemBlue)
                    self?.nextButton.buttonState = .enabled
                    self?.nextButton.setTitle("auth_birthDate_button_title".localized(), for: .normal)
                    if Locale.current.region == "KR" {
                        self?.textView.setBottomText(title: "auth_birthDate_age_noti_kr".localized(), color: .SystemBlue)
                    } else {
                        self?.textView.setBottomText(title: "auth_birthDate_age_noti".localized(), color: .SystemBlue)
                    }
                } else {
                    self?.nextButton.buttonState = .disabled
                    self?.nextButton.setTitle("auth_birthDate_button_title".localized(), for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    //MARK: - set view config
    private func setLayout() {
        self.view.addSubviews([textView, datepickerBackgroundView])
        datepickerBackgroundView.addSubview(datepicker)
        
        textView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 65))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }

        datepickerBackgroundView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 288))
        }
        datepicker.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 39))
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 36))
        }
        self.nextButton.snp.remakeConstraints {
            $0.bottom.equalTo(self.datepickerBackgroundView.snp.top).inset(-ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.navigationView.setTitle(title: "auth_email_Verify_navigation_title".localized())
        super.setTitleLabel(title: "auth_birthDate_title".localized(), subTitle: "auth_birthDate_sub_title".localized())
        super.setNextButtonTitle(title: "auth_birthDate_button_title".localized())
    }
    
    private func setBottomLineText() {
        if Locale.current.region == "KR" {
            self.textView.setBottomText(title: "auth_birthDate_age_noti_kr".localized(), color: .PrimaryWhiteAlternative)
        } else {
            self.textView.setBottomText(title: "auth_birthDate_age_noti".localized(), color: .PrimaryWhiteAlternative)
        }
    }
    
    private var textView = AuthDatePickView()
    private var datepickerBackgroundView = UIView().then {
        $0.backgroundColor = .black
    }
    private var datepicker = UIDatePicker().then {
        $0.locale = .autoupdatingCurrent
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
    }
    
}
