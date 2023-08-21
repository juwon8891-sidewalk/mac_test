import Foundation
import UIKit

class SplashCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .splash
    var splashViewController: SplashVC
    
    func start() {
        self.splashViewController.viewModel = SplashViewModel(coordinator: self)
        self.navigationController.pushViewController(splashViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToTabbar() {
        let tabbarCoordinator = AppCoordinator(self.navigationController)
        self.childCoordinators.append(tabbarCoordinator)
        tabbarCoordinator.finishDelegate = self
        tabbarCoordinator.start()
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.splashViewController = SplashVC()
    }
}
extension SplashCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
