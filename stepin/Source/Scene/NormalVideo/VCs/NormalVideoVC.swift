import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class NormalVideoVC: UIViewController {
    var viewModel: NormalVideoViewModel?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.bindViewModel()
        self.setLayout()
        self.setCollectionViewLayout()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubviews([collectionView, titleNavigationView])
        
        titleNavigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    internal func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppeared: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      backButtonDidTapped: self.titleNavigationView.backButton.rx.tap.asObservable(),
                                                      collectionView: self.collectionView),
                                          disposeBag: disposeBag)
        output?.navigationTitle
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] title in
                self?.titleNavigationView.setTitle(title: title)
            })
        
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
    
    private func setCollectionViewLayout() {
        self.collectionView.register(NormalCVC.self, forCellWithReuseIdentifier: NormalCVC.identifier)
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = .init(width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.height)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private var titleNavigationView = TitleNavigationView()
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
        $0.alwaysBounceVertical = true
        $0.contentInsetAdjustmentBehavior = .never
    }
}
