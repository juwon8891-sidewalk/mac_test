import Foundation
import UIKit

class SettingCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .setting
    var settingViewController: SettingVC
    
    func start() {
        self.navigationController.pushViewController(self.settingViewController, animated: true)
        settingViewController.viewModel = SettingViewModel(coordinator: self)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.settingViewController = SettingVC()
    }
    
    func pushToManageBlockUserView() {
//        let blockCoordinator = BlockUserCoordinator(self.navigationController)
//        let manageBlockViewController = blockCoordinator.manageBlockViewController
//        self.childCoordinators.append(blockCoordinator)
//        blockCoordinator.finishDelegate = self
//        blockCoordinator.start()
    }
    func pushToTermsAndConditionView() {
        let termsCoordinator = WebCoordinator(self.navigationController,
                                              url: Constants.eulaURL,
                                              type: .none)
        let termsViewController = termsCoordinator.webViewController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
    }
    func pushToPrivacyView() {
        let termsCoordinator = WebCoordinator(self.navigationController,
                                              url: Constants.privacyURL,
                                              type: .none)
        let termsViewController = termsCoordinator.webViewController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
    }
    func pushToEULAView() {
        let termsCoordinator = WebCoordinator(self.navigationController,
                                              url: Constants.eulaURL,
                                              type: .none)
        let termsViewController = termsCoordinator.webViewController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
        
    }
    func pushToNewsBoardView() {
        let termsCoordinator = WebCoordinator(self.navigationController,
                                              url: Constants.newsBoardURL,
                                              type: .none)
        let termsViewController = termsCoordinator.webViewController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
    }
    
    
}
extension SettingCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
