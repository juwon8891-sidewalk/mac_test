import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ManageBlockVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: ManageBlockViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let output = self.viewModel?.transform(from: .init(viewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                           didInitTableView: self.tableView),
                                               disposeBag: disposeBag)
        output?.isTableViewEmpty
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                self?.emptyView.isHidden = !state
            })
        
        self.navigationView.backButtonCompletion = {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setLayout() {
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([tableView, emptyView, navigationView])
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        navigationView.setRightButtonHidden()
        self.navigationView.setTitle(title: "manageblock_navigation_title".localized())
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        let refreshControll = UIRefreshControl()
        refreshControll.backgroundColor = .clear
        refreshControll.tintColor = .stepinBlack40
        self.tableView.refreshControl = refreshControll
        tableView.register(BlockUserTVC.self, forCellReuseIdentifier: BlockUserTVC.identifier)
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        self.setEmptyViewLayout()
    }
    
    private func setEmptyViewLayout() {
        emptyView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        emptyView.addSubview(emptyViewTitle)
        emptyViewTitle.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        emptyView.isHidden = true
    }
    
    private var emptyView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    
    private var emptyViewTitle = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.text = "manageblock_empty_view_title".localized()
        $0.textColor = .stepinWhite100
    }
    private var navigationView = TitleNavigationView()
    private var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .stepinBlack100
        $0.separatorStyle = .none
    }
}
extension ManageBlockVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.setWidth(value: 60)
    }
}
