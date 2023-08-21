import UIKit
import RxSwift
import RxRelay

class InboxVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: InboxViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.setTableView()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      tableView: self.tableView,
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable()),
                                          disposeBag: disposeBag)
    }
    
    private func setTableView() {
        tableView.register(InboxTVC.self, forCellReuseIdentifier: InboxTVC.identifier)
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, tableView])
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        navigationView.setTitle(title: "inbox_navigation_title".localized())
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private var navigationView = TitleNavigationView()
    private var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .stepinBlack100
        $0.separatorStyle = .none
    }
}
