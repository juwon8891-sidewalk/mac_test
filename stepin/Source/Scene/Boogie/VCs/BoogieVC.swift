import UIKit
import RxSwift
import Then
import SnapKit
import RxRelay

class BoogieVC: UIViewController {
    var viewModel: BoogieViewModel?
    var disposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setCollectionViewLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("부기 뷰디드 로드")
        self.bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.setLayout()

    }
    
    internal func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppeared: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      collectionView: self.collectionView),
                                          disposeBag: disposeBag)
        
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
    
    private func setLayout() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubviews([collectionView, topGradientView, topHashTagCategoryView, bottomCategoryView])
        
        topHashTagCategoryView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 15))
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        topGradientView.addGradient(to: topGradientView,
                                    colors: [UIColor.stepinBlack100.cgColor, UIColor.clear.cgColor],
                                    startPoint: .topCenter,
                                    endPoint: .bottomCenter)
        topGradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 80))
        }
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.tabBarController!.tabBar.snp.top)
        }
        
        bottomCategoryView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.tabBarController!.tabBar.snp.top).inset(ScreenUtils.setWidth(value: -20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            //탭바 높이만큼 수정 필요
        }
    }
    
    private func setCollectionViewLayout() {
        self.collectionView.register(BoogieVideoCVC.self, forCellWithReuseIdentifier: BoogieVideoCVC.identifier)
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = .init(width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.height - self.tabBarController!.tabBar.frame.height)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private let topHashTagCategoryView = TopCategoryView()
    private let bottomCategoryView = BottomCategoryView()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .clear
        $0.bounces = true
        $0.isPagingEnabled = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    private var topGradientView = UIView(frame: .init(origin: .zero, size: .init(width: UIScreen.main.bounds.width,
                                                                                 height: ScreenUtils.setWidth(value: 80))))
}
