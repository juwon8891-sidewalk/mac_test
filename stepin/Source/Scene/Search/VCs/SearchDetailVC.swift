import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

class SearchDetailVC: UIViewController {
    var viewModel: SearchDetailViewModel?
    var disposeBag = DisposeBag()
    var keyword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setLayout()
        self.setCollectionViewLayout()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        self.navigationView.setTitle(text: self.keyword)
        let output = viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      textField: self.navigationView.textField,
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      searchButtonTapped: self.navigationView.searchButton.rx.tap.asObservable(),
                                                      topCategoryView: self.topCategoryView,
                                                      hotVideoCollectionView: self.hotVideoCollectionView,
                                                      accountCollectionView: self.accountCollectionView,
                                                      danceCollectionView: self.danceCollectionView,
                                                      hashTagCollectionView: self.hashTagCollectionView,
                                                      autoCompleteCollectionView: self.autoCompleteView),
                                          disposeBag: disposeBag)
        
        output?.hotVideoCollectionBringToSubView
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.view.bringSubviewToFront(self!.hotVideoCollectionView)
            })
            .disposed(by: disposeBag)
        
        output?.accountCollectionViewBringToSubView
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.view.bringSubviewToFront(self!.accountCollectionView)
            })
            .disposed(by: disposeBag)
        
        output?.danceCollectionViewBringToSubView
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.view.bringSubviewToFront(self!.danceCollectionView)
            })
            .disposed(by: disposeBag)
        
        output?.hashtagCollectionViewBringToSubView
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.view.bringSubviewToFront(self!.hashTagCollectionView)
            })
            .disposed(by: disposeBag)
        
        output?.autoCompleteViewIshidden
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                self?.autoCompleteView.isHidden = state
                self?.view.bringSubviewToFront(self!.autoCompleteView)
            })
            .disposed(by: disposeBag)
    }
    
    private func setCollectionViewLayout() {
        let hotCollectionlayout = UICollectionViewFlowLayout()
        hotCollectionlayout.minimumLineSpacing = 3
        hotCollectionlayout.minimumInteritemSpacing = 3
        hotCollectionlayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 16) / 3.0,
                                              height: ScreenUtils.setWidth(value: 150))
        self.hotVideoCollectionView.collectionView.setCollectionViewLayout(hotCollectionlayout, animated: false)
        
        let accountCollectionLayout = UICollectionViewFlowLayout()
        accountCollectionLayout.minimumLineSpacing = 20
        accountCollectionLayout.minimumInteritemSpacing = 20
        accountCollectionLayout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                                  height: ScreenUtils.setWidth(value: 40))
        self.accountCollectionView.collectionView.setCollectionViewLayout(accountCollectionLayout, animated: false)
        
        let danceCollectionLayout = UICollectionViewFlowLayout()
        danceCollectionLayout.minimumLineSpacing = 20
        danceCollectionLayout.minimumInteritemSpacing = 20
        danceCollectionLayout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                                height: ScreenUtils.setWidth(value: 46))
        self.danceCollectionView.collectionView.setCollectionViewLayout(danceCollectionLayout, animated: false)
        
        let hashTagCollectionLayout = UICollectionViewFlowLayout()
        hashTagCollectionLayout.minimumLineSpacing = 20
        hashTagCollectionLayout.minimumInteritemSpacing = 20
        hashTagCollectionLayout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                                  height: ScreenUtils.setWidth(value: 40))
        self.hashTagCollectionView.collectionView.setCollectionViewLayout(hashTagCollectionLayout, animated: false)
        
        let autoCompletCollectionLayout = UICollectionViewFlowLayout()
        autoCompletCollectionLayout.minimumLineSpacing = 20
        autoCompletCollectionLayout.minimumInteritemSpacing = 20
        autoCompletCollectionLayout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                                      height: ScreenUtils.setWidth(value: 40))
        self.autoCompleteView.collectionView.setCollectionViewLayout(autoCompletCollectionLayout, animated: false)
        
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, topCategoryView, accountCollectionView, danceCollectionView, hashTagCollectionView, hotVideoCollectionView, autoCompleteView])
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.topCategoryView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        
        self.hotVideoCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.topCategoryView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.accountCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.topCategoryView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.danceCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.topCategoryView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.hashTagCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.topCategoryView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.autoCompleteView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.autoCompleteView.isHidden = true
    }
    
    private var navigationView = SearchNavigationView()
    private var topCategoryView = SearchViewTopCategoryView()
    private var autoCompleteView = DefaultSearchView()
    private var hotVideoCollectionView = DefaultSearchView()
    private var accountCollectionView = DefaultSearchView()
    private var danceCollectionView = DefaultSearchView()
    private var hashTagCollectionView = DefaultSearchView()
}
