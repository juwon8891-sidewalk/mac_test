import Foundation
import UIKit

class SearchViewCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .search
    var searchViewController: SearchVC
    
    func start() {
        self.searchViewController.viewModel = SearchViewModel(coordinator: self,
                                                              videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                              danceRepository: DanceRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                              hashTagRepository: HashTagRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(searchViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToSearchDetail(keyword: String) {
        let searchDetailCoordinator = SearchDetailCoordinator(self.navigationController)
        let searchDetailViewController = searchDetailCoordinator.searchViewController
        self.childCoordinators.append(searchDetailCoordinator)
        searchDetailCoordinator.finishDelegate = self
        searchDetailCoordinator.start(keyword: keyword)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.searchViewController = SearchVC()
    }
}
extension SearchViewCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
