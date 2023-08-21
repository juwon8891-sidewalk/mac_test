import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay

class VideoBottomSheet: UIView {
    var viewModel: BottomSheetViewModel?
    var disposeBag = DisposeBag()
    
    var showAlertCompleteion: (() -> Void)?
    
    init(size: CGSize) {
        super.init(frame: .init(origin: .zero, size: size))
        self.setLayout()
        self.viewModel = BottomSheetViewModel(transitionView: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func bindViewModel() {
        let output = viewModel?.transform(from: .init(bottomHandleScrol: self.touchAreaView.rx.panGesture().asObservable(),
                                                      followButton: self.followButton,
                                                      saveButton: nil,
                                                      shareButton: self.shareButton,
                                                      boostButton: self.boostButton,
                                                      deleteButton: nil,
                                                      saveDanceButton: self.saveDanceButton,
                                                      blockUserDanceButton: self.blockingButton,
                                                      reportButtonButton: self.reportButton,
                                                      modifyButton: nil,
                                                      deleteAlertButton: nil),
                                          disposeBag: disposeBag)
        output?.isCompletedCopy
            .withUnretained(self)
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(
                    name: .didLinkCopyed,
                    object: nil
                )
            })
            .disposed(by: disposeBag)
        
        output?.isReportButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                NotificationCenter.default.post(
                    name: .didReportButtonTapped,
                    object: data
                )
            })
            .disposed(by: disposeBag)
        
        output?.isReadyToShareLink
            .withUnretained(self)
            .subscribe(onNext: { (_, link) in
                self.setShareContent(link: link)
            })
            .disposed(by: disposeBag)
        
        output?.isBoostComplete
            .withUnretained(self)
            .bind(onNext: { (view, state) in
                if state {
                    view.boostButton.changeBoostButtonDisabled()
                } else {
                    view.boostButton.changeBoostButtonEnabled()
                }
            })
            .disposed(by: disposeBag)
        
        output?.showBoostAlert
            .withUnretained(self)
            .bind(onNext: { (view, state) in
                DispatchQueue.main.async {
                    guard let completion = view.showAlertCompleteion else {return}
                    completion()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showPermissionDeniedAlert() {
        let alertController = UIAlertController(
            title: "접근 권한 필요",
            message: "사진 저장을 위해 접근 권한이 필요합니다. 설정에서 권한을 변경해주세요.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        // 현재 뷰 컨트롤러에서 알림창을 표시하도록 설정
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func setShareContent(link: String) {
        var items: [Any] = [link]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF,
            .openInIBooks,
            .print,
            .saveToCameraRoll
        ]
        
        DispatchQueue.main.async {
            activityViewController.popoverPresentationController?.sourceView = self
            self.findViewController()?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.addSubviews([touchAreaView, buttonStackView, gradientView, blockingButton, reportButton, saveDanceButton])
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        self.clipsToBounds = true
        touchAreaView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        touchAreaView.addSubview(bottomHandleView)
        touchAreaView.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        bottomHandleView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(ScreenUtils.setWidth(value: 135))
        }
        bottomHandleView.layer.cornerRadius = ScreenUtils.setWidth(value: 3)
        
        followButton.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        shareButton.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        boostButton.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        boostButton.isButtonTextColorChange(color: .stepinWhite20)
        
        self.buttonStackView.snp.makeConstraints {
            $0.top.equalTo(self.touchAreaView.snp.bottom).offset(ScreenUtils.setWidth(value: 27))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 72))
        }
        self.buttonStackView.addArrangeSubViews([followButton, shareButton, boostButton])
        
        gradientView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(1)
        }
        self.setButtonConfig(button: blockingButton,
                             title: "mypage_bottomsheet_blocking".localized(),
                             image: ImageLiterals.icBlocking,
                             titleColor: .stepinWhite100)
        self.setButtonConfig(button: reportButton,
                             title: "mypage_bottomsheet_Report".localized(),
                             image: ImageLiterals.icReport,
                             titleColor: .stepinRed100)
        self.setButtonConfig(button: saveDanceButton,
                             title: "bottom_sheet_save_video_title".localized(),
                             image: ImageLiterals.icSaveVideo,
                             titleColor: .stepinWhite100)
        saveDanceButton.snp.makeConstraints {
            $0.top.equalTo(gradientView.snp.bottom).offset(ScreenUtils.setWidth(value: 25))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 150))
            $0.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        blockingButton.snp.makeConstraints {
            $0.top.equalTo(saveDanceButton.snp.bottom).offset(ScreenUtils.setWidth(value: 34))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 150))
            $0.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        reportButton.snp.makeConstraints {
            $0.top.equalTo(blockingButton.snp.bottom).offset(ScreenUtils.setWidth(value: 34))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 150))
            $0.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        
    }
    
    internal func setButtonConfig(button: UIButton,
                                  title: String,
                                  image: UIImage,
                                  titleColor: UIColor) {
        print(button)
        button.tintColor = .stepinBlack100
        button.backgroundColor = .stepinBlack100
        var config = UIButton.Configuration.plain()
        config.image = image
        config.baseForegroundColor = titleColor
        config.attributedTitle = title.setAttributeString(textColor: titleColor,
                                                          font: .suitMediumFont(ofSize: 16))
        button.configuration = config
        button.imageView?.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        button.titleLabel?.snp.makeConstraints {
            $0.leading.equalTo(button.imageView!.snp.trailing).offset(ScreenUtils.setWidth(value: 16))
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
    }
    
    
    internal let touchAreaView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    internal let bottomHandleView = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
    internal let followButton = SquareButton(title: "mypage_follow_button_title".localized(), image: ImageLiterals.icFollow_select)
    internal let shareButton = SquareButton(title: "mypage_bottomsheet_share".localized(), image: ImageLiterals.icShare)
    internal let boostButton = SquareButton(title: "mypage_bottomsheet_boost".localized(), image: ImageLiterals.icBoost_unselect)
    private let buttonStackView = UIStackView().then {
        $0.spacing = 22.adjusted
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    private let gradientView = HorizontalGradientView(width: ScreenUtils.setWidth(value: 343))
    internal let saveDanceButton = UIButton().then {
        $0.backgroundColor = .stepinBlack100
        $0.setTitle("bottom_sheet_save_video_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
    }
    internal let blockingButton = UIButton().then {
        $0.backgroundColor = .stepinBlack100
        $0.setTitle("block_view_unblock_button_title".localized(), for: .selected)
        $0.setTitle("block_view_block_button_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
    }
    internal let reportButton = UIButton().then {
        $0.backgroundColor = .stepinBlack100
    }
}
