import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class SettingVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: SettingViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let output = self.viewModel?.transform(from: .init(didInitTableView: self.tableView,
                                                           didTableViewCellTapped: self.tableView.rx.itemSelected.asObservable(),
                                                           signOutAlertView: self.signUpAlertView,
                                                           deleteAccountAlertView: self.deleteAccountAlertView),
                                               disposeBag: disposeBag)
        self.navigationView.backButtonCompletion = {
            self.navigationController?.popViewController(animated: true)
        }
        
        output?.blurViewTouchSelct.bind(onNext: { state in
            self.view.endEditing(state)
        })
    }
    
    private func setLayout() {
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, tableView, signUpAlertView, deleteAccountAlertView])
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        navigationView.setRightButtonHidden()
        self.navigationView.setTitle(title: "setting_navigation_title".localized())
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        tableView.register(SettingTVC.self, forCellReuseIdentifier: SettingTVC.identifier)
        signUpAlertView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        signUpAlertView.alpha = 0
        signUpAlertView.isHidden = true
        
        deleteAccountAlertView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        deleteAccountAlertView.alpha = 0
        deleteAccountAlertView.isHidden = true
        
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    private var navigationView = TitleNavigationView()
    private var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .stepinBlack100
        $0.separatorStyle = .none
    }
    private let signUpAlertView = SignOutAlertView(type: .signOut)
    private let deleteAccountAlertView = SignOutAlertView(type: .deleteAccount)
}
extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.setWidth(value: 94)
    }
}
