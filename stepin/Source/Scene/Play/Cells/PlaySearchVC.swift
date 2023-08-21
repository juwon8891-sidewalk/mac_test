import UIKit
import RxSwift
import Then
import SnapKit
import RxRelay

class PlaySearchVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: PlaySearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setTableViewConfig()
        self.setLayout()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let output = self.viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                           textFieldDidEditing: self.navigationView.textField.rx.text.orEmpty.asObservable(),
                                                           textField: self.navigationView.textField,
                                                           backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                           searchButtonTapped: self.navigationView.searchButton.rx.tap.asObservable(),
                                                           defaultSearchTableView: self.defaultTableView,
                                                           autoCompleteTableView: self.autoCompleteTableView),
                                               disposeBag: disposeBag)
       
        output?.defaultSearchCollectionViewHidden
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                DispatchQueue.main.async {
                    self?.defaultTableView.isHidden = false
                    self?.autoCompleteTableView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        output?.autoCompleteCollectionViewHidden
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                DispatchQueue.main.async {
                    self?.defaultTableView.isHidden = true
                    self?.autoCompleteTableView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setTableViewConfig() {
        self.defaultTableView.register(PlayDefaultSearchHeaderView.self, forHeaderFooterViewReuseIdentifier: PlayDefaultSearchHeaderView.identifier)
        self.defaultTableView.register(PlayDefaultSearchTVC.self, forCellReuseIdentifier: PlayDefaultSearchTVC.identifier)
        self.autoCompleteTableView.register(PlayDanceTableViewCell.self, forCellReuseIdentifier: PlayDanceTableViewCell.reuseIdentifier)
    }
    
    private func setLayout() {
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubviews([backGroundImageView, navigationView, defaultTableView, autoCompleteTableView])
        self.backGroundImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.defaultTableView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.autoCompleteTableView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.autoCompleteTableView.isHidden = true
    }
    
    private let backGroundImageView = UIImageView(image: ImageLiterals.playBackground)
    private let navigationView = SearchNavigationView()
    private var defaultTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.tag = 1
        $0.separatorStyle = .none
    }
    private var autoCompleteTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.tag = 2
        $0.separatorStyle = .none
    }
}
