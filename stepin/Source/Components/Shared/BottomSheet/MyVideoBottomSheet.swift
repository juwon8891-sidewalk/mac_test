import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxRelay

class MyVideoBottomSheet: UIView {
    var viewModel: BottomSheetViewModel?
    var disposeBag = DisposeBag()
    
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
                                                      followButton: nil,
                                                      saveButton: nil,
                                                      shareButton: self.shareButton,
                                                      boostButton: nil,
                                                      deleteButton: self.deletetButton,
                                                      saveDanceButton: self.saveDanceButton,
                                                      blockUserDanceButton: nil,
                                                      reportButtonButton: nil,
                                                      modifyButton: self.modifyButton,
                                                      deleteAlertButton: self.deleteAlertView.okButton),
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
        
        output?.isReadyToShareLink
            .withUnretained(self)
            .subscribe(onNext: { (_, link) in
                self.setShareContent(link: link)
            })
            .disposed(by: disposeBag)
        
        self.deleteAlertView.cancelButtonTappedCompletion = {
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.deleteAlertView.alpha = 0
            } completion: { _ in
                self.deleteAlertView.isHidden = true
            }
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
        self.addSubviews([touchAreaView, buttonStackView, gradientView, saveDanceButton, deletetButton, deleteAlertView])
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        self.clipsToBounds = true
        touchAreaView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        touchAreaView.addSubview(bottomHandleView)
        bottomHandleView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(ScreenUtils.setWidth(value: 135))
        }
        bottomHandleView.layer.cornerRadius = ScreenUtils.setWidth(value: 3)
        
        shareButton.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        boostButton.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        boostButton.changeBoostButtonDisabled()
        boostButton.isUserInteractionEnabled = false
        modifyButton.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        
        self.buttonStackView.snp.makeConstraints {
            $0.top.equalTo(self.touchAreaView.snp.bottom).offset(ScreenUtils.setWidth(value: 27))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 72))
        }
        gradientView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(1)
        }
        self.buttonStackView.addArrangeSubViews([modifyButton, shareButton, boostButton])
        
        self.setButtonConfig(button: deletetButton,
                             title: "mypage_bottomsheet_delete".localized(),
                             image: SDSIcon.icDelete,
                             titleColor: .stepinYellow)
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
        
        deletetButton.snp.makeConstraints {
            $0.top.equalTo(saveDanceButton.snp.bottom).offset(28.adjusted)
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 150))
            $0.height.equalTo(ScreenUtils.setWidth(value: 24))
        }

    }
    
    internal func setButtonConfig(button: UIButton,
                                 title: String,
                                 image: UIImage,
                                 titleColor: UIColor) {
        button.tintColor = .stepinBlack100
        button.backgroundColor = .stepinBlack100
        var config = UIButton.Configuration.plain()
        config.automaticallyUpdateForSelection = false
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
    @objc func deletebuttonClicked() {
        self.deleteAlertView.alpha = 1
        self.deleteAlertView.isHidden = false
    }

    internal let touchAreaView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    internal let bottomHandleView = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
    internal let shareButton = SquareButton(title: "mypage_bottomsheet_share".localized(), image: ImageLiterals.icShare)
    internal let boostButton = SquareButton(title: "mypage_bottomsheet_boost".localized(), image: ImageLiterals.icBoost_unselect)
    internal let modifyButton = SquareButton(title: "mypage_bottomsheet_modify".localized(), image: ImageLiterals.icModify)
    
    private let gradientView = HorizontalGradientView(width: ScreenUtils.setWidth(value: 343))

    internal lazy var deletetButton = UIButton().then {
        $0.backgroundColor = .stepinBlack100
        $0.setTitle("mypage_bottomsheet_delete".localized(), for: .normal)
        $0.setTitleColor(.stepinYellow, for: .selected)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
        $0.addTarget(self, action: #selector(deletebuttonClicked), for: .touchUpInside)
    }
    internal let saveDanceButton = UIButton().then {
        $0.backgroundColor = .stepinBlack100
        $0.setTitle("bottom_sheet_save_video_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
    }
    private let buttonStackView = UIStackView().then {
        $0.spacing = ScreenUtils.setWidth(value: 18)
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    let deleteAlertView = DeleteDanceAlertView()
}
