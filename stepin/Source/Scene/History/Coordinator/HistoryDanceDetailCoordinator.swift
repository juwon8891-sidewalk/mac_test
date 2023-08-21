import Foundation
import UIKit

class HistoryDanceDetailCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .history
    var historyViewController: HistoryDanceDetailVC
    
    func start() {
        self.navigationController.pushViewController(historyViewController, animated: true)
    }
    
    func start(data: HistoryVideoDataModel) {
        self.historyViewController.viewModel = HistoryDanceDetailViewModel(coordinator: self, danceData: data)
        self.navigationController.pushViewController(historyViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: false)
    }
    
    func pushToEditVideoView(data: HistoryVideoDataModel) {
        let editVideoDetailCoordinator = EditVideoCoordinator(self.navigationController)
        let editVideoViewController = editVideoDetailCoordinator.editVideoViewController
        self.childCoordinators.append(editVideoDetailCoordinator)
        editVideoDetailCoordinator.finishDelegate = self
        editVideoDetailCoordinator.start(data: data)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.historyViewController = HistoryDanceDetailVC()
    }
}
extension HistoryDanceDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
