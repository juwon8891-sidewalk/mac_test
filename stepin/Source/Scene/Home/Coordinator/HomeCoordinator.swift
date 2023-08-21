import Foundation
import UIKit

class HomeCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .home
    var homeViewController: HomeVC
    
    func start() {
        self.homeViewController.viewModel = HomeViewModel(coordinator: self,
                                                          homeRepository: HomeRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.homeViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.homeViewController = HomeVC()
    }
    
    func pushToDanceView(danceId: String) {
        let danceViewCoordinator = DanceViewCoordinator(self.navigationController)
        let danceViewController = danceViewCoordinator.danceViewController
        danceViewCoordinator.danceId = danceId
        self.childCoordinators.append(danceViewCoordinator)
        danceViewCoordinator.finishDelegate = self
        danceViewCoordinator.start()
    }
    
    func pushToSearchView() {
        let searchViewCoordinator = SearchViewCoordinator(self.navigationController)
        let searchViewController = searchViewCoordinator.searchViewController
        self.childCoordinators.append(searchViewCoordinator)
        searchViewCoordinator.finishDelegate = self
        searchViewCoordinator.start()
    }
    
    func pushToInbox() {
        let inboxCoordinator = InboxCoordinator(self.navigationController)
        let inboxViewController = inboxCoordinator.inboxViewController
        self.childCoordinators.append(inboxCoordinator)
        inboxCoordinator.finishDelegate = self
        inboxCoordinator.start()
    }
    
    func pushToStoreView() {
        let storeViewCoordinator = StoreViewCoordinators(self.navigationController)
        self.childCoordinators.append(storeViewCoordinator)
        storeViewCoordinator.finishDelegate = self
        storeViewCoordinator.start()
    }
    /**
     임시
     */
    func pushToLogin() {
        let searchViewCoordinator = LoginCoordinator(self.navigationController)
        let searchViewController = searchViewCoordinator.loginViewController
        self.childCoordinators.append(searchViewCoordinator)
        searchViewCoordinator.finishDelegate = self
        searchViewCoordinator.start()
    }
    
    func presentToComment(videoId: String) {
        let commentCoordinator = CommentViewCoordinator(self.navigationController)
        let commentViewContolloer = commentCoordinator.commentViewController
        commentViewContolloer.viewModel?.videoId = videoId
        self.childCoordinators.append(commentCoordinator)
        commentCoordinator.finishDelegate = self
        commentCoordinator.startComment(videoId: videoId)
    }
    
    func presentBottomSheet(userId: String,
                            videoId: String,
                            isFollowed: Bool,
                            isBlocked: Bool,
                            isBoosted: Bool,
                            type: BottomSheetType) {
        let bottomSheetCoordinator = BottomSheetCoordinator(self.navigationController)
        let bottomSheetViewContolloer = bottomSheetCoordinator.bottomSheetViewController
        self.childCoordinators.append(bottomSheetCoordinator)
        bottomSheetCoordinator.finishDelegate = self
        bottomSheetCoordinator.startData(userId: userId,
                                         videoId: videoId,
                                         isFollowed: isFollowed,
                                         isBlocked: isBlocked,
                                         isBoosted: isBoosted,
                                         type: type)
    }
    
}

extension HomeCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
