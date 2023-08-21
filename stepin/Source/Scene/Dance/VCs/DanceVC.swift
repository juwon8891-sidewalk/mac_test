import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DanceVC: UIViewController {
    var viewModel: DanceViewModel?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
        setTableViewConfig()
        setCollectionViewConfig()
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppeared: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      rankingButtonTapped: self.rankingButton.rx.tap.asObservable(),
                                                      hotButtonTapped: self.hotButton.rx.tap.asObservable(),
                                                      gameStartButtonTapped: self.gameStartButton.rx.tapGesture().asObservable(),
                                                      danceInfoView: self.danceInfoView,
                                                      playAlertView: self.playAlertView,
                                                      collectionView: self.hotCollectionView,
                                                      tableView: self.rankingTableView),
                                          disposeBag: disposeBag)
        
        output?.didSelectViewShadow
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                if state {
                    self!.selectThemeBackgroundView.drawShadow(color: .stepinBlack100,
                                                               opacity: 0.8,
                                                               offset: CGSize(width: 0,
                                                                              height: self!.selectThemeBackgroundView.frame.height / 2),
                                                               radius: ScreenUtils.setWidth(value: 10))
                    self!.selectThemeBackgroundView.clipsToBounds = false
                } else {
                    self?.selectThemeBackgroundView.layer.shadowOpacity = 0
                }
            })
            .disposed(by: disposeBag)
        
        output?.didRankingButtonTapped
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.rankingButton.isSelected = true
                    self?.hotButton.isSelected = false
                    self?.rankingButton.titleLabel?.font = .suitBoldFont(ofSize: 20)
                    self?.hotButton.titleLabel?.font = .suitMediumFont(ofSize: 20)
                }
            })
            .disposed(by: disposeBag)
        
        output?.didHotButtonTapped
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.hotButton.isSelected = true
                    self?.rankingButton.isSelected = false
                    self?.hotButton.titleLabel?.font = .suitBoldFont(ofSize: 20)
                    self?.rankingButton.titleLabel?.font = .suitMediumFont(ofSize: 20)
                }
            })
            .disposed(by: disposeBag)
        
        output?.isRankingViewEmpty
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                self!.rankingEmptyLabel.isHidden = !state
            })
            .disposed(by: disposeBag)
        
        output?.isHotDanceViewEmpty
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                self!.hotEmptyLabel.isHidden = !state
            })
            .disposed(by: disposeBag)
        
        output?.didPlayButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self?.playAlertView.isHidden = false
                    self?.playAlertView.alpha = 1
                }
            })
            .disposed(by: disposeBag)
        
        output?.didCancelButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self?.playAlertView.alpha = 0
                } completion: { _ in
                    self?.playAlertView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        output?.didStartLoadData
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                self.view.showLoadingIndicator()
            })
            .disposed(by: disposeBag)
        
        output?.didLoadData
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                self.view.removeLoadingIndicator()
                self.gameStartButton.setAnimation()
            })
            .disposed(by: disposeBag)
        
        
 
        self.danceInfoView.viewModel = DanceInfoViewModel(danceId: self.viewModel?.danceId ?? "")
        self.danceInfoView.bindViewModel()
    }
    
    private func setTableViewConfig() {
        self.rankingTableView.register(RankingTVC.self, forCellReuseIdentifier: RankingTVC.identifier)
        self.rankingTableView.register(DanceRankingHeaderView.self, forHeaderFooterViewReuseIdentifier: DanceRankingHeaderView.identifier)
    }
    
    private func setCollectionViewConfig() {
        self.hotCollectionView.register(HotVideoCVC.self, forCellWithReuseIdentifier: HotVideoCVC.identifier)
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 3
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 16) / 3.0,
                                     height: ScreenUtils.setWidth(value: 150))
        self.hotCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    private func setLayout() {
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = .stepinBlack100
        selectThemeBackgroundView.addSubviews([rankingButton, hotButton])
        rankingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        hotButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(rankingButton.snp.trailing).offset(ScreenUtils.setWidth(value: 40))
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        
        self.view.addSubviews([navigationView, danceInfoView, rankingTableView, hotCollectionView, gameStartButton, selectThemeBackgroundView, playAlertView])
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.navigationView.setTitle(title: "dance_view_navigation_title".localized())
        self.danceInfoView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        self.selectThemeBackgroundView.snp.makeConstraints {
            $0.top.equalTo(danceInfoView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 65))
        }
        self.rankingTableView.snp.makeConstraints {
            $0.top.equalTo(selectThemeBackgroundView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.hotCollectionView.snp.makeConstraints {
            $0.top.equalTo(selectThemeBackgroundView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview()
        }
        self.hotCollectionView.isHidden = true
        self.rankingButton.isSelected = true
        gameStartButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 120))
        }
        self.rankingTableView.addSubview(rankingEmptyLabel)
        self.hotCollectionView.addSubview(hotEmptyLabel)
        rankingEmptyLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 40))
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 40))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 40))
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        rankingEmptyLabel.isHidden = true
        hotEmptyLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 40))
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 40))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 40))
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        hotEmptyLabel.isHidden = true
        self.playAlertView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        self.playAlertView.isHidden = true
    }
    
    private var navigationView = TitleNavigationView()
    private var danceInfoView = DanceInfoView()
    private var selectThemeBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    private var rankingButton = UIButton().then {
        $0.setTitle("dance_view_ranking_button_title".localized(), for: .normal)
        $0.tintColor = .clear
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.setTitleColor(.stepinWhite40, for: .normal)
        $0.titleLabel?.font = .suitMediumFont(ofSize: 20)
    }
    private var hotButton = UIButton().then {
        $0.setTitle("dance_view_hot_button_title".localized(), for: .normal)
        $0.tintColor = .clear
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.setTitleColor(.stepinWhite40, for: .normal)
        $0.titleLabel?.font = .suitBoldFont(ofSize: 20)
    }
    private var rankingTableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.backgroundColor = .stepinBlack100
        $0.showsVerticalScrollIndicator = false
        $0.separatorStyle = .none
    }
    private var hotCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .stepinBlack100
        $0.bounces = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    private var gameStartButton = AnimatingGameStartButton()
    private var rankingEmptyLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.text = "dance_view_empty_view_description".localized()
    }
    private var hotEmptyLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.text = "dance_view_empty_view_description".localized()
    }
    private var playAlertView = SelectGameAlertView()
}
