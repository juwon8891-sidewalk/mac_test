import Foundation
import UIKit

class VideoMoreCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .boogie
    var moreViewController: VideoMoreVC
    
    func start() {
        moreViewController.viewModel = VideoMoreViewModel(coordinator: self)
        self.navigationController.pushViewController(self.moreViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.moreViewController = VideoMoreVC()
    }
    
    
}
//extension BoogieCoordinator: CoordinatorFinishDelegate {
//    func coordinatorDidFinish(childCoordinator: Coordinator) {
//        self.childCoordinators = self.childCoordinators
//            .filter { $0.type != childCoordinator.type }
//    }
//}
