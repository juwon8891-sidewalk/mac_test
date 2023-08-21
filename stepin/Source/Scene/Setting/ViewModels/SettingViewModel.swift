import Foundation
import RxCocoa
import RxSwift
import RxDataSources

final class SettingViewModel {
    internal weak var coordinator: SettingCoordinator?
    var tokenUtils = TokenUtils()
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    init(coordinator: SettingCoordinator) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let didInitTableView: UITableView
        let didTableViewCellTapped: Observable<IndexPath>
        let signOutAlertView: SignOutAlertView
        let deleteAccountAlertView: SignOutAlertView
        
    }
    
    struct Output {
        var cellOutputData = PublishRelay<SettingTableviewDataSection>()
        var blurViewTouchSelct = PublishRelay<Bool>()
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        let dataSource = RxTableViewSectionedReloadDataSource<SettingTableviewDataSection>(
        configureCell: { [weak self] dataSource, tableview, indexPath, item in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: SettingTVC.identifier) as? SettingTVC else { return UITableViewCell() }
            cell.setData(title: item.title,
                         description: item.description,
                         type: item.type,
                         tag: indexPath.row)
          return cell
        })
        
        Observable
            .just(settingModel)
            .bind(to: input.didInitTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        input.didTableViewCellTapped
            .subscribe(onNext: {[weak self] index in
                switch index.row {
                case 0:
                    self?.coordinator?.pushToManageBlockUserView()
                case 1:
                    self?.coordinator?.pushToTermsAndConditionView()
                case 2:
                    self?.coordinator?.pushToPrivacyView()
                case 3:
                    self?.coordinator?.pushToEULAView()
                case 4:
                    self?.coordinator?.pushToNewsBoardView()
                case 6:
                    //logout
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            input.signOutAlertView.isHidden = false
                            input.signOutAlertView.alpha = 1
                        }
                    }
                case 7:
                    //delete
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            input.deleteAccountAlertView.isHidden = false
                            input.deleteAccountAlertView.alpha = 1
                        }
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        input.signOutAlertView.okButtonCompletion = {
            self.removeUserInfo()
        }
        
        input.signOutAlertView.cancelButtonCompletion = {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    input.signOutAlertView.alpha = 0
                } completion: { _ in
                    input.signOutAlertView.isHidden = true
                }
            }
        }
        
        input.deleteAccountAlertView.okButtonCompletion = {
            DispatchQueue.main.async {
                self.deleteUser(disposeBag: disposeBag)
            }
        }
        
        input.deleteAccountAlertView.cancelButtonCompletion = {
            output.blurViewTouchSelct.accept(true)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    input.deleteAccountAlertView.alpha = 0
                } completion: { _ in
                    input.deleteAccountAlertView.isHidden = true
                }
            }
        }
        input.deleteAccountAlertView.blurViewTouchCompletion = {
            output.blurViewTouchSelct.accept(true)
        }
        
        return output
    }
    
    
    private func deleteUser(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .flatMap{ [weak self] _ in (self?.userRepository.deleteWidthdrawalUser())! }
            .subscribe(onNext: { [weak self] result in
                self?.removeUserInfo()
                print(result)
            })
            .disposed(by: disposeBag)
    }
    
    private func exitApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            exit(0)
        }
    }
    
    private func removeUserInfo() {
        self.tokenUtils.delete(UserDefaultKey.accessToken)
        self.tokenUtils.delete(UserDefaultKey.refreshToken)
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.name)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.identifierName)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.userId)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.profileUrl)
        UserDefaults.standard.set(false, forKey: UserDefaultKey.LoginStatus)
        
        exitApp()
    }
    
}
