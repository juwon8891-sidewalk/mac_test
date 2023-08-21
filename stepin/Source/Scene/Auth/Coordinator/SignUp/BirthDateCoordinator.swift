import UIKit

final class BirthDateCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var birthDateViewController: BirthDateVC
    
    func start() {
        self.birthDateViewController.viewModel = BirthDateViewModel(coordinator: self,
                                                             signUpRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.birthDateViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.birthDateViewController = BirthDateVC()
        
    }
    
    func pushToNextView() {
        let coordinator = EnterIdCoordinator(self.navigationController)
        let viewController = coordinator.enterIdViewController
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
        print("NextButtonClicked")
    }
}
extension BirthDateCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
