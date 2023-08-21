import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

enum DidTapFollowViewType{
    case follower
    case following
}

enum FollowerViewType {
    case my
    case other
}

class ShowFollowerVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: ShowFollowerViewModel?
    var type: DidTapFollowViewType?
    var viewType: FollowerViewType?
    var userId: String = ""
    var nickName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        setLayout()
        setTableViewConfig()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.type == .following {
            self.scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width, y: 0), animated: false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationView.setTitle(title: self.userId)
    }

    
    private func bindViewModel() {
        self.navigationView.setTitle(title: nickName)
        let output = self.viewModel?.transform(from: .init(didViewAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                           didInitFollowersTableView: self.followerTableView,
                                                           didInitFollowingTableView: self.followingTableView,
                                                           didScrollViewHorizontalScrolled: self.scrollView.rx.contentOffset.asObservable(),
                                                           didFollowerSearchBarUsed: self.followerSearchBar.textField.rx.text.orEmpty.asObservable(),
                                                           didFollowingSearchBarUsed: self.followingSearchBar.textField.rx.text.orEmpty.asObservable(),
                                                           didDeleteFollowerTapped: self.deleteUserAlertView.okButton.rx.tap.asObservable(),
                                                           didCancelDeleteFollowerButtonTapped: self.deleteUserAlertView.cancelButton.rx.tap.asObservable(),
                                                           didDeleteUserAlertView: self.deleteUserAlertView,
                                                           navigationView: self.navigationView),
                                                           disposeBag: disposeBag)
        output?.searchHeaderState
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: .show)
            .drive(onNext: { [weak self] state in
                switch state {
                case .show:
                    self?.view.endEditing(false)
                    UIView.animate(withDuration: 0.5) {
                        self?.followerTableView.snp.remakeConstraints {
                            $0.top.equalTo(self!.followerSearchBarBackgroundView.snp.bottom)
                            $0.leading.equalTo(self!.scrollView.snp.leading)
                            $0.bottom.equalTo(self!.view.snp.bottom)
                            $0.width.equalTo(UIScreen.main.bounds.width)
                        }
                        self!.followingTableView.snp.remakeConstraints {
                            $0.top.equalTo(self!.followingSearchBarBackgroundView.snp.bottom)
                            $0.leading.equalTo(self!.followerTableView.snp.trailing)
                            $0.bottom.equalTo(self!.view.snp.bottom)
                            $0.trailing.equalTo(self!.scrollView.snp.trailing)
                            $0.width.equalTo(UIScreen.main.bounds.width)
                        }
                        self!.followerSearchBarBackgroundView.transform = .identity
                        self!.followingSearchBarBackgroundView.transform = .identity
                        self?.scrollView.layoutIfNeeded()
                    }
                case .hidden:
                    UIView.animate(withDuration: 0.5) {
                        self?.view.endEditing(true)
                        self?.followerTableView.snp.remakeConstraints {
                            $0.top.equalTo(self!.tabbar.snp.bottom)
                            $0.leading.equalTo(self!.scrollView.snp.leading)
                            $0.bottom.equalTo(self!.view.snp.bottom)
                            $0.width.equalTo(UIScreen.main.bounds.width)
                        }
                        self!.followingTableView.snp.remakeConstraints {
                            $0.top.equalTo(self!.tabbar.snp.bottom)
                            $0.leading.equalTo(self!.followerTableView.snp.trailing)
                            $0.bottom.equalTo(self!.view.snp.bottom)
                            $0.trailing.equalTo(self!.scrollView.snp.trailing)
                            $0.width.equalTo(UIScreen.main.bounds.width)
                        }
                        self!.followerSearchBarBackgroundView.transform = CGAffineTransform(translationX: 0, y: ScreenUtils.setWidth(value: -110))
                        self!.followingSearchBarBackgroundView.transform = CGAffineTransform(translationX: 0, y: ScreenUtils.setWidth(value: -110))
                        self?.scrollView.layoutIfNeeded()
                    }
                }
            })
            .disposed(by: disposeBag)


        
        output?.tabbarLeftPadding
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: ScreenUtils.setWidth(value: 18))
            .drive(onNext: { [weak self] value in
                self?.tabbar.didMoveToTab(xPosition: value)
            })
            .disposed(by: disposeBag)
        
        output?.didRemoveFollowerButtonClicked
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.setAlertView()
                }
            })
            .disposed(by: disposeBag)
        
        output?.didCancelDeleteFollowerButton
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.removeAlertView()
                }
            })
        
        
        tabbar.didFollowingTabClickedCompletion = {
            self.scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width, y: 0), animated: true)
        }
        
        tabbar.didFollowerTabClickedCompletion = {
            self.scrollView.setContentOffset(.centerRight, animated: true)
        }
        
        navigationView.backButtonCompletion = {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    private func setAlertView() {
        self.view.addSubview(gausianBackgroundView)
        gausianBackgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        gausianBackgroundView.addSubview(deleteUserAlertView)
        deleteUserAlertView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 272))
            $0.height.equalTo(ScreenUtils.setWidth(value: 257))
        }
        deleteUserAlertView.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        deleteUserAlertView.clipsToBounds = true
        
    }
    
    private func removeAlertView() {
        self.gausianBackgroundView.removeFromSuperview()
    }
    
    private func setTableViewConfig() {
        let followerRefreshControl = UIRefreshControl()
        followerRefreshControl.backgroundColor = .clear
        followerRefreshControl.tintColor = .stepinBlack40
        followerTableView.refreshControl = followerRefreshControl
        
        let followingRefreshControl = UIRefreshControl()
        followingRefreshControl.backgroundColor = .clear
        followingRefreshControl.tintColor = .stepinBlack40
        followingTableView.refreshControl = followingRefreshControl
        
        
        followerTableView.register(FollowerTVC.self, forCellReuseIdentifier: FollowerTVC.identifier)
        followingTableView.register(FollowingTVC.self, forCellReuseIdentifier: FollowingTVC.identifier)
        
        followerTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        followingTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, tabbar, scrollView])
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        navigationView.setRightButtonHidden()
        
        tabbar.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
                
        scrollView.addSubviews([followerTableView, followingTableView, followerSearchBarBackgroundView, followingSearchBarBackgroundView])
        followerSearchBarBackgroundView.snp.makeConstraints {
            $0.top.equalTo(tabbar.snp.bottom)
            $0.leading.equalTo(scrollView.snp.leading)
            $0.height.equalTo(ScreenUtils.setWidth(value: 90))
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        followingSearchBarBackgroundView.snp.makeConstraints {
            $0.top.equalTo(tabbar.snp.bottom)
            $0.leading.equalTo(followerSearchBarBackgroundView.snp.trailing)
            $0.trailing.equalTo(scrollView.snp.trailing)
            $0.height.equalTo(ScreenUtils.setWidth(value: 90))
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(tabbar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        followerTableView.snp.makeConstraints {
            $0.top.equalTo(followerSearchBarBackgroundView.snp.bottom)
            $0.leading.equalTo(scrollView.snp.leading)
            $0.bottom.equalTo(self.view.snp.bottom)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        followingTableView.snp.makeConstraints {
            $0.top.equalTo(followingSearchBarBackgroundView.snp.bottom)
            $0.leading.equalTo(followerTableView.snp.trailing)
            $0.bottom.equalTo(self.view.snp.bottom)
            $0.trailing.equalTo(scrollView.snp.trailing)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }

        followerSearchBarBackgroundView.addSubview(followerSearchBar)
        followingSearchBarBackgroundView.addSubview(followingSearchBar)
        followerSearchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 50))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        followingSearchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 50))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        
        if self.type == .follower {
            tabbar.changeFollowerLabelColor(color: .stepinWhite100)
            tabbar.changeFollowingLabelColor(color: .stepinWhite40)
        } else {
            tabbar.changeFollowingLabelColor(color: .stepinWhite100)
            tabbar.changeFollowerLabelColor(color: .stepinWhite40)
        }
    }
    private var navigationView = TitleNavigationView().then {
        $0.backgroundColor = .stepinBlack100
    }
    private var tabbar = ShowFollowerTabbar()
    private var followerSearchBar = CustomSearchBar(width: ScreenUtils.setWidth(value: 276))
    private var followerSearchBarBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    
    private var followingSearchBar = CustomSearchBar(width: ScreenUtils.setWidth(value: 276))
    private var followingSearchBarBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    
    private var scrollView = UIScrollView().then {
        $0.isScrollEnabled = false
        $0.showsHorizontalScrollIndicator = false
    }
    private var contentView = UIView()
    private var followerTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .stepinBlack100
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    private var followingTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .stepinBlack100
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    private var gausianBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack50
    }
    private var deleteUserAlertView = DeleteUserAlertView()
}
extension ShowFollowerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.setWidth(value: 60)
    }
}
