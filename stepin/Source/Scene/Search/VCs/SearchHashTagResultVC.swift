import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class SearchHashTagResultVC: UIViewController {
    var viewModel: SearchHashTagResultViewModel?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.setCollectionViewLayout()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      hashTagResultCollectionView: self.hashTagResultView),
                                          disposeBag: disposeBag)
        
        output?.isHashTagResultEmpty
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.emptyLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        
        output?.navigationTitle
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] title in
                self?.navigationView.setTitle(title: "# " + title)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setCollectionViewLayout() {
        let hashTagResultCollectionLayout = UICollectionViewFlowLayout()
        hashTagResultCollectionLayout.minimumLineSpacing = 3
        hashTagResultCollectionLayout.minimumInteritemSpacing = 3
        hashTagResultCollectionLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 16) / 3.0,
                                                        height: ScreenUtils.setWidth(value: 150))
        self.hashTagResultView.collectionView.setCollectionViewLayout(hashTagResultCollectionLayout, animated: false)
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, hashTagResultView, emptyLabel])
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.hashTagResultView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.emptyLabel.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        self.emptyLabel.isHidden = true
    }
    
    private var navigationView = TitleNavigationView()
    private var hashTagResultView = DefaultSearchView()
    private var emptyLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "searchView_hashtags_tab_empty_description".localized()
    }

}
