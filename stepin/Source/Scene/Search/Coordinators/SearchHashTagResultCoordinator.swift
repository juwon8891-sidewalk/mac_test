import Foundation
import UIKit

class SearchHashTagResultCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .search
    var searchViewController: SearchHashTagResultVC
    
    func start() {
        self.searchViewController.viewModel = SearchHashTagResultViewModel(coordinator: self,
                                                                           videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(searchViewController, animated: true)
    }
    
    func start(hashTagId: String, hashTitle: String) {
        self.searchViewController.viewModel = SearchHashTagResultViewModel(coordinator: self,
                                                                           videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.searchViewController.viewModel?.hashTitle = hashTitle
        self.searchViewController.viewModel?.hashTagId = hashTagId
        self.navigationController.pushViewController(searchViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToVideoView(videoData: [NormalVideoCollectionViewDataSection],
                         pageNum: Int,
                         type: callVideoType,
                         indexPath: IndexPath) {
        let normalVideoViewCoordinator = NormalViewCoordinator(self.navigationController)
        let normalVideoViewController = normalVideoViewCoordinator.normalVideoViewController
        self.childCoordinators.append(normalVideoViewCoordinator)
        normalVideoViewCoordinator.finishDelegate = self
        normalVideoViewCoordinator.start(videoData: videoData,
                                         pageNum: pageNum,
                                         type: type,
                                         indexPath: indexPath)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.searchViewController = SearchHashTagResultVC()
    }
}
extension SearchHashTagResultCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
