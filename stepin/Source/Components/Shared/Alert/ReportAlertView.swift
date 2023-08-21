import UIKit

class ReportAlertView: BaseAlertView {
    var didReportItemCompletion: ((String) -> Void)?
    var viewModel: AlertViewModel?

    override init() {
        super.init()
        setLayout()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func bindViewModel() {
        self.viewModel = AlertViewModel(alertView: self)
        let output = self.viewModel?.transform(from: .init(hateSpeachButtonTapped: dontLikeReportButton.rx.tap.asObservable(),
                                                           spamMessageButtonTapped: spamReportButton.rx.tap.asObservable(),
                                                           NudityButtonTapped: nakedReportButton.rx.tap.asObservable(),
                                                           fraudButtonTapped: fraoudReportButton.rx.tap.asObservable(),
                                                           cancelButtonTap: cancelButton.rx.tap.asObservable()),
                                               disposeBag: disposeBag)
        output?.isReportComplete
            .withUnretained(self)
            .subscribe(onNext: { _ in
                DispatchQueue.main.async {
                    self.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        output?.didCancelButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                DispatchQueue.main.async {
                    self.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
   
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.alertTitleLabel.text = "alert_report_title".localized()
        self.alertContentView.addSubviews([dontLikeReportButton, spamReportButton, nakedReportButton, fraoudReportButton])
        dontLikeReportButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 36))
        }
        spamReportButton.snp.makeConstraints {
            $0.top.equalTo(dontLikeReportButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 52))
        }
        nakedReportButton.snp.makeConstraints {
            $0.top.equalTo(spamReportButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 52))
        }
        fraoudReportButton.snp.makeConstraints {
            $0.top.equalTo(nakedReportButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 52))
            
        }
    }
    
    internal let dontLikeReportButton = ReportButton(title: "alert_report_dont_like".localized(), isBottomGradientHidden: false)
    internal let spamReportButton = ReportButton(title: "alert_report_spam".localized(), isBottomGradientHidden: false)
    internal let nakedReportButton = ReportButton(title: "alert_report_naked".localized(), isBottomGradientHidden: false)
    internal let fraoudReportButton = ReportButton(title: "alert_report_fraoud".localized(), isBottomGradientHidden: true)
}
