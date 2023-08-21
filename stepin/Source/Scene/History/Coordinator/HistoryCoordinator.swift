import Foundation
import UIKit

class HistoryCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .history
    var historyViewController: HistoryVC
    
    func start() {
        self.historyViewController.viewModel = HistoryViewModel(coordinator: self)
        self.navigationController.pushViewController(historyViewController, animated: true)

    }
    
    func presentToDetailView(data: HistoryVideoDataModel) {
        let historyDetailCoordinator = HistoryDanceDetailCoordinator(self.navigationController)
        let detailViewController = historyDetailCoordinator.historyViewController
        self.childCoordinators.append(historyDetailCoordinator)
        historyDetailCoordinator.finishDelegate = self
        historyDetailCoordinator.start(data: data)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.historyViewController = HistoryVC()
    }
    
    
}
extension HistoryCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
