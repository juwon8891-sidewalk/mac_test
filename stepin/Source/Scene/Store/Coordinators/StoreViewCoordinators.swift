import UIKit

final class StoreViewCoordinators: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .store
    var storeViewController: StoreVC
    
    func start() {
        self.storeViewController.viewModel = StoreViewModel(coordinator: self)
        self.storeViewController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(self.storeViewController, animated: true)
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: true)
    }
    
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.storeViewController = StoreVC()
        
    }
    
}

