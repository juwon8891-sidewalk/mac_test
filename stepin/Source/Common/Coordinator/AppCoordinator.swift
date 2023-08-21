import UIKit

final class AppCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType { .app }
    var window: UIWindow?

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func start() {
        self.showTabbarFlow()
    }
    
    func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(self.navigationController)
        loginCoordinator.finishDelegate = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }
    
    func showTabbarFlow() {
        let tabbarCoordinator = TabbarCoordinator(self.navigationController)
        tabbarCoordinator.finishDelegate = self
        tabbarCoordinator.start()
        childCoordinators.append(tabbarCoordinator)
    }
    
    
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter({ $0.type != childCoordinator.type})
        self.navigationController.viewControllers.removeAll()
        
    }
    
    
}
