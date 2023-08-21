import UIKit
import SwiftUI
import Lottie
import SnapKit
import Then
import RxSwift
import RxRelay
import RxDataSources
import AVFoundation

class HomeVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: HomeViewModel?
    
    var currentIndex: CGFloat = 0
    var isOneStepPaging = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        bindViewModel()
//        setSSVLayout()
        setCSSVLayout()
        setLayout()
        setConfigCollectionView()
//        addObserver()
        print("홈 뷰디드 로드")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stepinButton.snp.remakeConstraints {
            $0.bottom.equalTo(self.tabBarController!.tabBar.snp.top).inset(ScreenUtils.setHeight(value: -20))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 161))
        }
    }
    
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(plusEnergyButtonTapped: self.navigationView.energyBar.addEnergyButton.rx.tap.asObservable(),
                                                      notiButtonTapped: self.navigationView.notiButton.rx.tap.asObservable(),
                                                      searchButtonTapped: self.navigationView.searchButton.rx.tap.asObservable(),
                                                      stepinButton: self.stepinButton,
                                                      viewDidAppeared: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      viewDidLayoutSubviews: self.rx.methodInvoked(#selector(viewDidLayoutSubviews))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      
                                                      energyBar: self.navigationView.energyBar,
                                                      signupButton: self.navigationView.signupbutton,
                                                      notiButton: self.navigationView.notiButton,
                                                      collectionView: self.collectionView),
                                          disposeBag: disposeBag)
        output?.currentDanceImage
            .withUnretained(self)
            .subscribe(onNext: { (_, path) in
                self.stepinButton.setImageView(imagePath: path)
            })
            .disposed(by: disposeBag)
        
        output?.isCelleSelected
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                if state {
                    self.viewModel?.isCellSelected = true
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else {return}
                        strongSelf.navigationView.isHidden = true
                        strongSelf.leftSoundWaveView.isHidden = true
                        strongSelf.rightSoundWaveView.isHidden = true
                        strongSelf.stepinButton.isHidden = true
                        
                        UIView.animate(withDuration: 0.3) {
                            strongSelf.collectionView.snp.remakeConstraints {
                                $0.top.bottom.leading.trailing.equalToSuperview()
                            }
                        } completion: { [weak self] _ in
                            guard let strongSelf = self else {return}
                            strongSelf.tabBarController?.tabBar.backgroundColor = .clear
                            strongSelf.tabBarController?.tabBar.isTranslucent = true
                                
                            strongSelf.collectionView.visibleCells.forEach {
                                let cell = $0 as? SuperShortFormCVC
                                
                                UIView.animate(withDuration: 0.3) {
                                    cell?.transform = .init(scaleX: UIScreen.main.bounds.width / cell!.videoView.frame.width,
                                                            y: UIScreen.main.bounds.height / cell!.videoView.frame.height)
                                    cell?.videoView.frame = .init(origin: .zero, size: UIScreen.main.bounds.size)
                                    cell?.videoView.playerLayer.frame = cell!.videoView.frame
                                    cell?.isCellSelected = true
                                    cell?.reduceView.isHidden = true
                                    cell?.magnifyView.isHidden = false
                                    cell?.setViewComponentHidden(state: true)
                                }
                            }
                            
                        }
                        strongSelf.collectionView.setCollectionViewLayout(strongSelf.getCollectionViewLayout(state: state),
                                                                          animated: false)
                    }
                } else {
                    self.viewModel?.isCellSelected = false
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else {return}
                        strongSelf.navigationView.isHidden = false
                        strongSelf.leftSoundWaveView.isHidden = false
                        strongSelf.rightSoundWaveView.isHidden = false
                        strongSelf.stepinButton.isHidden = false
                        
                        strongSelf.tabBarController?.tabBar.backgroundColor = .clear
                        strongSelf.tabBarController?.tabBar.isTranslucent = true
                        
                        UIView.animate(withDuration: 0.3) { [weak self] in
                            guard let strongSelf = self else {return}
                            strongSelf.collectionView.visibleCells.forEach { [weak self] in
                                let cell = $0 as? SuperShortFormCVC
                                UIView.animate(withDuration: 0.3) {
                                    cell?.transform = .init(scaleX: cell!.videoView.frame.width / UIScreen.main.bounds.width,
                                                            y: cell!.videoView.frame.height / UIScreen.main.bounds.height)
                                    cell?.videoView.frame = .init(origin: .zero,
                                                                  size: .init(width: 258.adjusted,
                                                                              height: 421.adjustedH))
                                    cell?.videoView.playerLayer.frame = .init(origin: .zero,
                                                                              size: .init(width: 258.adjusted,
                                                                                          height: 421.adjustedH))
                                    cell?.isCellSelected = false
                                    cell?.reduceView.isHidden = false
                                    cell?.magnifyView.isHidden = true
                                    cell?.setViewComponentHidden(state: false)
                                }
                            }
                            strongSelf.collectionView.setCollectionViewLayout(strongSelf.getCollectionViewLayout(state: state),
                                                                                       animated: false)
                            
                            
                        } completion: { [weak self] _ in
                            guard let strongSelf = self else {return}
                            strongSelf.collectionView.snp.remakeConstraints {
                                $0.top.equalTo(strongSelf.navigationView.snp.bottom)
                                $0.leading.trailing.equalToSuperview()
                                $0.bottom.equalTo(strongSelf.stepinButton.snp.top).inset(-20.adjusted)
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingStart
        
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                vc.view.showLoadingIndicator()
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingEnd
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                vc.view.removeLoadingIndicator()
            })
            .disposed(by: disposeBag)
        
    }
    private func getCurrentCellIndex() -> IndexPath {
        var visiableRect = CGRect()
        visiableRect.origin = self.collectionView.contentOffset
        visiableRect.size = self.collectionView.bounds.size
        let visibleRect = CGPoint(x: visiableRect.midX, y: visiableRect.midY)
        guard let currentCellIndexPath = self.collectionView.indexPathForItem(at: visibleRect) else { return IndexPath(row: 0, section: 0)}
        
        return currentCellIndexPath
    }
    
    private func getCollectionViewLayout(state: Bool) -> UICollectionViewFlowLayout{
        if state {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = UIScreen.main.bounds.size
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 0
            return layout
        } else {
            let layout = HomeCollectionViewLayout()
            layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 22, right: 0)
            layout.itemSize = CGSize(width: ScreenUtils.setWidth(value: 258), height: ScreenUtils.setHeight(value: 421))
            layout.sideItemScale = ScreenUtils.setWidth(value: 138) / ScreenUtils.setWidth(value: 220)
            return layout
        }
    }
    
    
    private func setConfigCollectionView() {
        self.collectionView.register(SuperShortFormCVC.self,
                                     forCellWithReuseIdentifier: SuperShortFormCVC.reuseIdentifier)
        collectionView.decelerationRate = .fast
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func setLayout() {
        self.view.addSubviews([backgroundImageView, navigationView, stepinButton, rightSoundWaveView, leftSoundWaveView, ssvView!.view])
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
        ssvView!.view.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }

        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        stepinButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 161))
        }
        stepinButton.layer.shadowColor = UIColor.stepinWhite100.cgColor
        stepinButton.layer.shadowOpacity = 0.3
        stepinButton.layer.shadowRadius = ScreenUtils.setWidth(value: 5)
        stepinButton.clipsToBounds = false
        stepinButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
//        collectionView.snp.makeConstraints {
//            $0.top.equalTo(navigationView.snp.bottom)
//            $0.leading.trailing.equalToSuperview()
//            $0.bottom.equalTo(stepinButton.snp.top).inset(ScreenUtils.setWidth(value: -20))
//        }
        leftSoundWaveView.snp.makeConstraints {
            $0.trailing.equalTo(stepinButton.snp.leading).inset(ScreenUtils.setWidth(value: -20))
            $0.centerY.equalTo(stepinButton)
            $0.width.equalTo(ScreenUtils.setWidth(value: 44))
            $0.height.equalTo(ScreenUtils.setWidth(value: 36))
        }
        leftSoundWaveView.play()
        leftSoundWaveView.loopMode = .loop
        rightSoundWaveView.snp.makeConstraints {
            $0.leading.equalTo(stepinButton.snp.trailing).offset(ScreenUtils.setWidth(value: 20))
            $0.centerY.equalTo(stepinButton)
            $0.width.equalTo(ScreenUtils.setWidth(value: 44))
            $0.height.equalTo(ScreenUtils.setWidth(value: 36))
        }
        rightSoundWaveView.play()
        rightSoundWaveView.transform = CGAffineTransform(scaleX: -1, y: 1)
        rightSoundWaveView.loopMode = .loop
        setCollectionViewLayout()
    }
    
    private func setCollectionViewLayout() {
        let layout = HomeCollectionViewLayout()
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 22, right: 0)
        layout.itemSize = CGSize(width: ScreenUtils.setWidth(value: 258), height: ScreenUtils.setHeight(value: 421))
        layout.sideItemScale = ScreenUtils.setWidth(value: 138) / ScreenUtils.setWidth(value: 220)
        
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private let backgroundImageView = UIImageView(image: ImageLiterals.homeBackground)
    private var navigationView = HomeNavigationBar()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .clear
        $0.bounces = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    private var stepinButton = StepinButton(size: CGSize(width: ScreenUtils.setWidth(value: 161),
                                                         height: ScreenUtils.setWidth(value: 32)))
    private var leftSoundWaveView = LottieAnimationView(name: "music")
    private var rightSoundWaveView = LottieAnimationView(name: "music")
    
    
    // 슈숏 부
    private var ssvPageViewHandler: SSVPageViewHandler?
    private var ssvView : UIHostingController<CustomPageView>?
    
    
    private func setCSSVLayout() {
        self.ssvPageViewHandler = SSVPageViewHandler(direction: .Vertical, isFullScreen: false, itemWidth: 258.adjusted, itemHeight: 421.adjusted, itemOffset: 0, homeViewModel: viewModel!)
        
        self.ssvView = UIHostingController(rootView: CustomPageView(pageViewHandler: self.ssvPageViewHandler!)).then {
            $0.view.backgroundColor = .clear
        }
        
        self.ssvPageViewHandler?.setFullScreenCallback = setFullScreenCallback
    }
    
    private func setFullScreenCallback(isFullScreen: Bool) {
        DispatchQueue.main.async {
            if isFullScreen {
                self.tabBarController?.tabBar.backgroundColor = .clear
            }
            else {
                self.tabBarController?.tabBar.backgroundColor = .PrimaryBlackNormal
            }
        }
    }
    
}

class HomeCollectionViewLayout: UICollectionViewFlowLayout {
    
    public var sideItemScale: CGFloat = 0.3
    public var sideItemAlpha: CGFloat = 0.3
    public var spacing: CGFloat = 18
    
    public var isPagingEnabled: Bool = false
    
    private var isSetup: Bool = false
    
    override public func prepare() {
        super.prepare()
        if isSetup == false {
            setupLayout()
            isSetup = true
        }
    }
    
    private func setupLayout() {
        guard let collectionView = self.collectionView else {return}
        
        let collectionViewSize = collectionView.bounds.size
        
        let xInset = (collectionViewSize.width - self.itemSize.width) / 2
        let yInset = (collectionViewSize.height - self.itemSize.height) / 2
        
        self.sectionInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
        let itemWidth = self.itemSize.width
        
        let scaledItemOffset =  (itemWidth - (itemWidth * (self.sideItemScale + (1 - self.sideItemScale) / 2))) / 2
        self.minimumLineSpacing = spacing - scaledItemOffset
        
        self.scrollDirection = .horizontal
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
              let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
        else { return nil }
        
        return attributes.map({ self.transformLayoutAttributes(attributes: $0) })
    }
    
    private func transformLayoutAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else {return attributes}
        
        let collectionCenter = collectionView.frame.size.width / 2
        let contentOffset = collectionView.contentOffset.x
        let center = attributes.center.x - contentOffset
        
        let maxDistance = 2 * (self.itemSize.width + self.minimumLineSpacing)
        let distance = min(abs(collectionCenter - center), maxDistance)
        
        let ratio = (maxDistance - distance)/maxDistance
        
        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
        
        attributes.alpha = alpha
        
        //넘어간 것 알파값 조절
        if abs(collectionCenter - center) > maxDistance + 2 {
            UIView.animate(withDuration: 1, delay: 0) {
                attributes.alpha = 0
            }
        }
        
        let visibleRect = CGRect(origin: self.collectionView!.contentOffset, size: self.collectionView!.bounds.size)
        let dist = CGRectGetMidX(attributes.frame) - CGRectGetMidX(visibleRect)
        var transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        transform = CATransform3DTranslate(transform, 0, 0, -abs(dist/1000))
        attributes.transform3D = transform
        
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            return latestOffset
        }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
        
        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
//
extension HomeVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // item의 사이즈와 item 간의 간격 사이즈를 구해서 하나의 item 크기로 설정.
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        // targetContentOff을 이용하여 x좌표가 얼마나 이동했는지 확인
        // 이동한 x좌표 값과 item의 크기를 비교하여 몇 페이징이 될 것인지 값 설정
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        
        // scrollView, targetContentOffset의 좌표 값으로 스크롤 방향을 알 수 있다.
        // index를 반올림하여 사용하면 item의 절반 사이즈만큼 스크롤을 해야 페이징이 된다.
        // 스크로로 방향을 체크하여 올림,내림을 사용하면 좀 더 자연스러운 페이징 효과를 낼 수 있다.
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
            roundedIndex = ceil(index)
        } else {
            roundedIndex = round(index)
        }
        
        if isOneStepPaging {
            if currentIndex > roundedIndex {
                currentIndex -= 1
                roundedIndex = currentIndex
            } else if currentIndex < roundedIndex {
                currentIndex += 1
                roundedIndex = currentIndex
            }
        }
        
        // 위 코드를 통해 페이징 될 좌표값을 targetContentOffset에 대입하면 된다.
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}
