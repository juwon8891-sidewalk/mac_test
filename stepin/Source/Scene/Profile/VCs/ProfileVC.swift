import UIKit
import SDSKit
import RxSwift
import Lottie
import RxCocoa

class ProfileVC: UIViewController {
    internal var profileViewModel: ProfileViewModel?
    internal var coordinator: ProfileCoordinator?
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        self.view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.registerCell()
        self.bindProfileViewModel()
        self.setCollectionLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = .stepinBlack100
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    private func bindProfileViewModel() {
        let output = self.profileViewModel?.transform(from: .init(viewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                                  navigationRightButtonTap: self.profileView.titleNavigationBar.rightButton.rx.tap.asObservable(),
                                                                  backButtonTap: self.profileView.titleNavigationBar.backButton.rx.tap.asObservable(),
                                                                  collectionView: profileView.collectionView),
                                                      disposeBag: self.disposeBag)
        output?.profileViewType
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, type) in
                switch type {
                case .my:
                    self.profileView.titleNavigationBar.backButton.isHidden = true
                    self.profileView.titleNavigationBar.setRightButtonImage(image: SDSIcon.icSetting)
                    self.profileView.titleNavigationBar.rightButton.isHidden = false
                case .backButtonMy:
                    self.profileView.titleNavigationBar.backButton.isHidden = false
                    self.profileView.titleNavigationBar.setRightButtonImage(image: SDSIcon.icSetting)
                    self.profileView.titleNavigationBar.rightButton.isHidden = false
                case .other, .block:
                    self.profileView.titleNavigationBar.backButton.isHidden = false
                    self.profileView.titleNavigationBar.setRightButtonImage(image: SDSIcon.icMeatballs)
                    self.profileView.titleNavigationBar.rightButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        output?.navigationTitle
            .withUnretained(self)
            .bind(onNext: { (vc, title) in
                vc.profileView.titleNavigationBar.setTitle(title: title)
                vc.profileView.setBlockLabelText(userName: title)
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingStart
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                DispatchQueue.main.async {
                    vc.view.showLoadingIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingEnd
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                DispatchQueue.main.async {
                    vc.view.removeLoadingIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        output?.collectionViewOffset
            .withUnretained(self)
            .bind(onNext: {(vc, yOffset) in
                vc.didScrollCollectionView(yOffset: yOffset)
            })
            .disposed(by: disposeBag)
        
        output?.showShareBottomSheet
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, link) in
                vc.showShareBottomSheet(link: link)
            })
            .disposed(by: disposeBag)
        
        output?.profileViewType
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                if state != .my {
                    DispatchQueue.main.async {
                        self.tabBarController?.tabBar.isHidden = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tabBarController?.tabBar.isHidden = false
                    }
                }
                if state == .block {
                    DispatchQueue.main.async {
                        vc.profileView.blockLabel.isHidden = false
                        vc.profileView.collectionView.alwaysBounceVertical = false
                    }
                } else {
                    DispatchQueue.main.async {
                        vc.profileView.blockLabel.isHidden = true
                        vc.profileView.collectionView.alwaysBounceVertical = true
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.rightButtonstate
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                
            })
            .disposed(by: disposeBag)
        
        output?.leftButtonState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                
            })
            .disposed(by: disposeBag)
    }
    
    private func showShareBottomSheet(link: String) {
        var items: [Any] = [link]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .print,
        ]
        DispatchQueue.main.async {
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func didScrollCollectionView(yOffset: CGFloat) {
        if let headerView = self.profileView.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                                              at: [0, 0]) as? ProfileHeaderView {
            let alphaValue = 1 - yOffset * 0.003
            headerView.setAlphaWithView(alpha: alphaValue)
            print(headerView.alpha)
        }
        
    }
    
    private func registerCell() {
        self.profileView.collectionView.register(VideoPreviewCVC.self,
                                                 forCellWithReuseIdentifier: VideoPreviewCVC.identifier)
        self.profileView.collectionView.register(ProfileHeaderView.self,
                                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                 withReuseIdentifier: ProfileHeaderView.reuseIdentifier)
    }
    private func setCollectionLayout() {
        let layout = ProfileViewCustomCollectionViewFlowLayout()
        self.profileView.collectionView.setCollectionViewLayout(layout, animated: false)
        
    }
    
    private let profileView = ProfileView()
}
