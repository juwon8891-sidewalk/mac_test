import Foundation
import UIKit

class PracticeGameCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .game
    var practiceGameViewController: PracticeGameViewController
    
    func start() {
        self.practiceGameViewController.viewModel = PracticeGameViewModel(coordinator: self)
        self.navigationController.pushViewController(self.practiceGameViewController, animated: true)
    }
    
    func startToData(data: PlayDance) {
        self.practiceGameViewController.viewModel = PracticeGameViewModel(coordinator: self)
        self.practiceGameViewController.viewModel?.danceInfo = data
        self.navigationController.pushViewController(self.practiceGameViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: false)
    }

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.practiceGameViewController = PracticeGameViewController()
    }
    
}

//extension ChallengeGameCoordinator: CoordinatorFinishDelegate {
//    func coordinatorDidFinish(childCoordinator: Coordinator) {
//        self.childCoordinators = self.childCoordinators
//            .filter { $0.type != childCoordinator.type }
//    }
//}

