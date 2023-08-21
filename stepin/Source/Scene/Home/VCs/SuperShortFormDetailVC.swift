//import UIKit
//import RxSwift
//import SnapKit
//import Then
//
//class SuperShortFormDetailVC: UIViewController {
//    var disposeBag = DisposeBag()
//    var viewModel: SuperShortFormDetailViewModel?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setLayout()
//        setCollectionViewConfig()
//        bindViewModel()
//        initNoti()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.disposeViewData()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setSliderButtonLayout()
//        UIView.animate(withDuration: 0.5) {
//            self.animationView.alpha = 0
//        } completion: { _ in
//            self.animationView.isHidden = true
//        }
//    }
//    
//    private func disposeViewData() {
//        NotificationCenter.default.removeObserver(self,
//                                                  name: NSNotification.Name("SSF_CurrentVideo"),
//                                                  object: nil)
//        NotificationCenter.default.removeObserver(self,
//                                               name: NSNotification.Name("SSF_CurrentVideo_Video_Count"),
//                                               object: nil)
//        self.animationView.alpha = 1
//        self.animationView.isHidden = false
//    }
//    
//    private func bindViewModel() {
//        let output = viewModel?.transform(from: .init(backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
//                                                      searchButtonTapped: self.navigationView.searchButton.rx.tap.asObservable(),
//                                                      viewDidAppeared: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
//            .observe(on: MainScheduler.asyncInstance)
//            .map({ _ in })
//            .asObservable(),
//                                                      viewDidDisappeared: self.rx.methodInvoked(#selector(viewDidDisappear(_:)))
//            .observe(on: MainScheduler.asyncInstance)
//            .map({ _ in })
//            .asObservable(),
//                                                      collectionView: self.collectionView),
//                                          disposeBag: disposeBag)
//    }
//    
//    private func setCollectionViewConfig() {
//        self.collectionView.register(SuperShortFormDetailCVC.self,
//                                     forCellWithReuseIdentifier: SuperShortFormDetailCVC.identifier)
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = UIScreen.main.bounds.size
//        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.minimumLineSpacing = 0
//        self.collectionView.setCollectionViewLayout(layout, animated: false)
//        self.collectionView.contentInsetAdjustmentBehavior = .never;
//    }
//    
//    private func setScoreViewConfig(value: String = "00.00") {
//        if value == "" { return }
//        var percentValue = Double(value)! / 100
//        var doubleValue = Double(value)!
//        
//        let strValue = String(format: "%.2f", doubleValue)
//        print(value, strValue)
//        scoreView.progressAnimation(duration: 1,
//                                    value: percentValue)
//        scoreView.setPercent(value: Double(strValue)!)
//    }
//    
//    private func initNoti() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(didRecieveNotiVideoData(_:)),
//                                               name: NSNotification.Name("SSF_CurrentVideo"),
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(setSeekBarLayout(_:)),
//                                               name: NSNotification.Name("SSF_CurrentVideo_Video_Count"),
//                                               object: nil)
//    }
//    
//    @objc private func didRecieveNotiVideoData(_ sender: NSNotification) {
//        let dataArray = sender.object as! [String]
//        //dataarray0번째 인덱스가 현재 재생중인 노래의 dance id
//        self.setScoreViewConfig(value: dataArray[1])
//        self.setSliderButtonImage(path: dataArray[2])
//        self.navigationView.setTitle(title: dataArray[3])
//    }
//    
//    @objc private func setSeekBarLayout(_ sender: NSNotification) {
//        let cnt = sender.object as! Int
//        self.view.subviews.forEach { view in
//            if view == self.seekBarView {
//                seekBarView?.removeFromSuperview()
//            }
//        }
////        self.seekBarView = CustomSeekBar(videoCount: cnt,
////                                         startTime: self,
////                                         endTime: T##[Float],
////                                         duration: T##Float,
////                                         valueController: T##ProgressValueController)
//        self.view.addSubview(seekBarView!)
//        seekBarView!.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview()
//            $0.bottom.equalTo(self.tabBarController!.tabBar.snp.top)
//            $0.height.equalTo(2)
//        }
//    }
//    
//    private func setSliderButtonLayout() {
//        self.sliderButton.snp.makeConstraints {
//            $0.bottom.equalTo(self.tabBarController!.tabBar.snp.top).offset(-ScreenUtils.setWidth(value: 18))
//            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
//            $0.width.equalTo(ScreenUtils.setWidth(value: 100))
//            $0.height.equalTo(ScreenUtils.setWidth(value: 32))
//        }
//        
//        sliderButton.isHidden = false
//        sliderButton.layer.shadowColor = UIColor.stepinWhite100.cgColor
//        sliderButton.layer.shadowOpacity = 0.5
//        sliderButton.layer.shadowRadius = ScreenUtils.setWidth(value: 15)
//        sliderButton.clipsToBounds = false
//        sliderButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
//    }
//    
//    private func setSliderButtonImage(path: String) {
//        guard let url = URL(string: path) else {return}
//        self.sliderButton.musicImageView.kf.setImage(with: url)
//    }
//    
//    private func setLayout() {
//        self.tabBarController?.tabBar.backgroundColor = .clear
//        self.tabBarController?.tabBar.backgroundImage = UIImage()
//        self.tabBarController?.tabBar.shadowImage = UIImage()
//        
//        self.tabBarController?.tabBar.isTranslucent = true
//        self.view.addSubviews([collectionView, navigationView, scoreView, sliderButton])
//        collectionView.snp.makeConstraints {
//            $0.top.bottom.leading.trailing.equalToSuperview()
//        }
//        navigationView.snp.makeConstraints {
//            $0.top.equalTo(self.view.safeAreaLayoutGuide)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
//        }
//        scoreView.snp.makeConstraints {
//            $0.top.equalTo(navigationView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
//            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
//            $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
//        }
//        sliderButton.isHidden = true
//        //animating
//        self.view.addSubview(animationView)
//        animationView.snp.makeConstraints {
//            $0.top.bottom.leading.trailing.equalToSuperview()
//        }
//    }
//    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        $0.setCollectionViewLayout(layout, animated: false)
//        $0.backgroundColor = .stepinBlack100
//        $0.bounces = true
//        $0.showsHorizontalScrollIndicator = false
//        $0.showsVerticalScrollIndicator = false
//        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        $0.isPagingEnabled = true
//        $0.contentInsetAdjustmentBehavior = .never
//    }
//    private let navigationView = SSFTopNavigationView()
//    private let scoreView = ScoreView(frame: .init(origin: .zero, size: CGSize(width: ScreenUtils.setWidth(value: 72),
//                                                                               height: ScreenUtils.setWidth(value: 72))))
//    private let sliderButton = SuperShortFormSlider(size: CGSize(width: ScreenUtils.setWidth(value: 100),
//                                                                 height: ScreenUtils.setWidth(value: 32)))
//    private var seekBarView: CustomSeekBar?
//    private var animationView = UIView().then {
//        $0.backgroundColor = .stepinBlack100
//    }
//}
//
