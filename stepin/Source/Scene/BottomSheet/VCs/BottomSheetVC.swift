import UIKit
import SDSKit
import RxSwift
import RxRelay

enum BottomSheetType {
    case otherPage
    case myVideo
    case otherVideo
    case notLogin
}


class BottomSheetVC: UIViewController {
    internal var coordinator: BottomSheetCoordinator?
    internal var type: BottomSheetType = .myVideo
    internal var userId: String = ""
    internal var videoId: String = ""
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var isBlocked: Bool = false
    var isFollowed: Bool = false
    var isBoosted: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.didNotificationInit()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setBlurAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotification()
        if isBeingDismissed {
            self.removeBlurAnimation()
        }
    }
    
    private func showReportAlertView() {
        DispatchQueue.main.async {
            self.reportAlertView.isHidden = false
        }
    }
    
    private func dismissReportAlertView() {
        DispatchQueue.main.async {
            self.reportAlertView.isHidden = true
        }
    }
    
    private func didNotificationInit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showLoadingIndicator),
            name: .showLoading,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideLoadingIndicator),
            name: .hideLoading,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLinkCopyComplete),
            name: .didLinkCopyed,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReportButtonTapped),
            name: .didReportButtonTapped,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setSaveVideoState(_:)),
            name: .didSaveVideoStart,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didVideoPermissionDenined),
            name: .videoPermissionDenined,
            object: nil
        )
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .hideLoading,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .showLoading,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .didLinkCopyed,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .didReportButtonTapped,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .didSaveVideoStart,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .videoPermissionDenined,
                                                  object: nil)
    }
    
    @objc private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.view.showLoadingIndicator()
        }
    }
    
    @objc private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.view.removeLoadingIndicator()
        }
    }
    
    @objc private func didVideoPermissionDenined() {
        let alertController = UIAlertController(
            title: "video_permission_title".localized(),
            message: "video_permission_description".localized(),
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func setSaveVideoState(_ sender: NSNotification) {
        if let state = sender.object as? Bool {
            DispatchQueue.main.async {
                if state {
                    self.loadingView.isHidden = false
                } else {
                    self.loadingView.isHidden = true
                }
            }
        }
    }
    
    @objc private func didReportButtonTapped(_ sender: NSNotification) {
        if let stringData = sender.object as? [String] {
            DispatchQueue.main.async {
                self.reportAlertView.isHidden = false
            }
            self.reportAlertView.viewModel?.videoId = stringData[0]
            self.reportAlertView.viewModel?.userId = stringData[1]
        }
    }
    
    @objc private func didLinkCopyComplete() {
        DispatchQueue.main.async {
            self.view.makeToast(title: "noti_link_copy_description".localized(), type: .blueCheck)
        }
    }
    
    private func setBlurAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.backGroundView.alpha = 1
        }
    }
    
    private func removeBlurAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.backGroundView.alpha = 0
        }
    }
    
    private func setLayout() {
        self.view.backgroundColor = .clear
        let paddingView = UIView()
        paddingView.backgroundColor = .stepinBlack100
        self.view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        backGroundView.alpha = 0
        switch self.type {
        case .otherPage:
            self.view.addSubviews([paddingView, myPageBottomSheetView, reportAlertView])
            myPageBottomSheetView.snp.makeConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(ScreenUtils.setWidth(value: 261))
            }
            paddingView.snp.makeConstraints {
                $0.top.equalTo(myPageBottomSheetView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
            reportAlertView.snp.makeConstraints {
                $0.top.bottom.leading.trailing.equalToSuperview()
            }
            reportAlertView.isHidden = true
            
            if self.isBlocked {
                myPageBottomSheetView.followButton.isButtonDisabled()
                myPageBottomSheetView.blockingButton.isSelected = self.isBlocked
            } else {
                if self.isFollowed {
                    myPageBottomSheetView.followButton.isFollowingButtonSelected()
                } else {
                    myPageBottomSheetView.followButton.isFollowingButtonUnselected()
                }
                
                if self.isBoosted {
                    myPageBottomSheetView.boostButton.changeBoostButtonEnabled()
                } else {
                    myPageBottomSheetView.boostButton.changeBoostButtonDisabled()
                }
            }
            
            myPageBottomSheetView.viewModel?.bottomSheetCoordinator = self.coordinator
            myPageBottomSheetView.viewModel?.userId = self.userId
            myPageBottomSheetView.viewModel?.videoId = self.videoId
            myPageBottomSheetView.bindViewModel()
        case .myVideo:
            self.view.addSubviews([paddingView, myVideoBottomSheetView, myVideoBottomSheetView.deleteAlertView])
            myVideoBottomSheetView.snp.makeConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(ScreenUtils.setWidth(value: 255))
            }
            paddingView.snp.makeConstraints {
                $0.top.equalTo(myVideoBottomSheetView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
            myVideoBottomSheetView.deleteAlertView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            myVideoBottomSheetView.deleteAlertView.isHidden = true
            
            myVideoBottomSheetView.viewModel?.bottomSheetCoordinator = self.coordinator
            myVideoBottomSheetView.viewModel?.userId = self.userId
            myVideoBottomSheetView.viewModel?.videoId = self.videoId
            myVideoBottomSheetView.bindViewModel()
        case .otherVideo:
            self.view.addSubviews([paddingView, videoBottomSheetView, reportAlertView])
            videoBottomSheetView.snp.makeConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(ScreenUtils.setWidth(value: 315))
            }
            paddingView.snp.makeConstraints {
                $0.top.equalTo(videoBottomSheetView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
            reportAlertView.snp.makeConstraints {
                $0.top.bottom.leading.trailing.equalToSuperview()
            }
            reportAlertView.isHidden = true
            
            if self.isBlocked {
                videoBottomSheetView.followButton.isButtonDisabled()
                videoBottomSheetView.blockingButton.isSelected = self.isBlocked
            } else {
                if self.isFollowed {
                    videoBottomSheetView.followButton.isFollowingButtonSelected()
                } else {
                    videoBottomSheetView.followButton.isFollowingButtonUnselected()
                }
                
                if self.isBoosted {
                    videoBottomSheetView.boostButton.changeBoostButtonEnabled()
                } else {
                    videoBottomSheetView.boostButton.changeBoostButtonDisabled()
                }
            }

            videoBottomSheetView.viewModel?.bottomSheetCoordinator = self.coordinator
            videoBottomSheetView.viewModel?.userId = self.userId
            videoBottomSheetView.viewModel?.videoId = self.videoId
            videoBottomSheetView.bindViewModel()
            
            videoBottomSheetView.showAlertCompleteion = { [weak self] in
                guard let strongSelf = self else {return}
                let alert = strongSelf.showSDSAlert(size: .init(width: 272.adjusted,
                                                           height: 292.adjusted),
                                               icon: SDSIcon.icBoost,
                                               title: "boost_alert_title".localized(),
                                               titleColor: .PrimaryWhiteNormal,
                                               description: "boost_alert_text".localized() + "\n\n" + "boost_alert_description".localized(),
                                               descriptionColor: .PrimaryWhiteNormal)
                
                alert.okButtonTapCompletion = { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.videoBottomSheetView.viewModel?.getBoostIsPossible(userId: strongSelf.userId,
                                                                       disposeBag: strongSelf.disposeBag)
                    strongSelf.hideSDSAlertView(alert)
                }
                
                alert.cancelButtonTapCompletion = { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.hideSDSAlertView(alert)
                }
            }
            
        default:
            break
        }
        self.view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        loadingView.isHidden = true
    }
    
    private var backGroundView = UIView().then {
        $0.backgroundColor = .PrimaryBlackAlternative
    }
    private var myPageBottomSheetView = MyPageBottomSheet(size: .init(width: UIScreen.main.bounds.width,
                                                                      height: ScreenUtils.setWidth(value: 261)))
    private var videoBottomSheetView = VideoBottomSheet(size: .init(width: UIScreen.main.bounds.width,
                                                                    height: ScreenUtils.setWidth(value: 315)))
    private var myVideoBottomSheetView = MyVideoBottomSheet(size: .init(width: UIScreen.main.bounds.width,
                                                                        height: ScreenUtils.setWidth(value: 255)))
    private var reportAlertView = ReportAlertView()
    private let loadingView = EditMyPageLoadingView()
}
