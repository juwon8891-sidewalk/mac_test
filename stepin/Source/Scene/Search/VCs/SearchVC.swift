import UIKit
import RxSwift
import Then
import SnapKit
import RxRelay

class SearchVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.hideKeyboardWhenTappedAround()
        self.setLayout()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      textFieldDidEditing: self.navigationView.textField.rx.text.orEmpty.asObservable(),
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      searchButtonTapped: self.navigationView.searchButton.rx.tap.asObservable(),
                                                      defaultSearchCollectionView: self.defaultSearchCollectionView,
                                                      autoCompleteCollectionView: self.autoCompleteCollectionView),
                                          disposeBag: disposeBag)

        output?.defaultSearchCollectionViewHidden
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                DispatchQueue.main.async {
                    self?.view.bringSubviewToFront(self!.defaultSearchCollectionView)
                }
            })
            .disposed(by: disposeBag)
        
        output?.autoCompleteCollectionViewHidden
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                DispatchQueue.main.async {
                    self?.view.bringSubviewToFront(self!.autoCompleteCollectionView)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, autoCompleteCollectionView, defaultSearchCollectionView])
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.defaultSearchCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.autoCompleteCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private var navigationView = SearchNavigationView()
    private var defaultSearchCollectionView = DefaultSearchView()
    private var autoCompleteCollectionView = DefaultSearchView()


}
