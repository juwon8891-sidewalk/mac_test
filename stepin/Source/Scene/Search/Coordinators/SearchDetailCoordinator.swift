import Foundation
import UIKit

class SearchDetailCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .search
    var searchViewController: SearchDetailVC
    
    func start() {
        self.searchViewController.viewModel = SearchDetailViewModel(coordinator: self,
                                                              videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                              danceRepository: DanceRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                              hashTagRepository: HashTagRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(searchViewController, animated: true)
    }
    
    func start(keyword: String) {
        self.searchViewController.keyword = keyword
        self.searchViewController.viewModel = SearchDetailViewModel(coordinator: self,
                                                              videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                              danceRepository: DanceRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                              hashTagRepository: HashTagRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(searchViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToDanceView(danceId: String) {
        let danceViewCoordinator = DanceViewCoordinator(self.navigationController)
        let danceViewController = danceViewCoordinator.danceViewController
        danceViewCoordinator.danceId = danceId
        self.childCoordinators.append(danceViewCoordinator)
        danceViewCoordinator.finishDelegate = self
        danceViewCoordinator.start()
    }
    
    func pushToVideoView(videoData: [NormalVideoCollectionViewDataSection],
                         pageNum: Int,
                         cellVideoType: callVideoType,
                         indexPath: IndexPath) {
        let videoViewCoordinator = NormalViewCoordinator(self.navigationController)
        let videoViewController = videoViewCoordinator.normalVideoViewController
        self.childCoordinators.append(videoViewCoordinator)
        videoViewCoordinator.finishDelegate = self
        videoViewCoordinator.start(videoData: videoData,
                                   pageNum: pageNum,
                                   type: cellVideoType,
                                   indexPath: indexPath)
    }
    
    func pushToMyProfileView() {
        let myProfileCoordinator = ProfileCoordinator(self.navigationController)
        let myProfileViewController = myProfileCoordinator.profileViewController
        self.childCoordinators.append(myProfileCoordinator)
        myProfileCoordinator.finishDelegate = self
        myProfileCoordinator.start()
    }
    
    func pushToOtherProfileView(userId: String) {
//        let otherProfileCoordinator = OtherMyPageCoordinator(self.navigationController)
//        let otherProfileViewController = otherProfileCoordinator.otherMyPageViewController
//        self.childCoordinators.append(otherProfileCoordinator)
//        otherProfileCoordinator.finishDelegate = self
//        otherProfileCoordinator.start(userId: userId)
    }
    
    func pushToHashTagResult(hashTagId: String, hashTagTitle: String) {
        let searchResultViewCoordinator = SearchHashTagResultCoordinator(self.navigationController)
        let searchResultViewController = searchResultViewCoordinator.searchViewController
        self.childCoordinators.append(searchResultViewCoordinator)
        searchResultViewCoordinator.finishDelegate = self
        searchResultViewCoordinator.start(hashTagId: hashTagId, hashTitle: hashTagTitle)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.searchViewController = SearchDetailVC()
    }
}
extension SearchDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
