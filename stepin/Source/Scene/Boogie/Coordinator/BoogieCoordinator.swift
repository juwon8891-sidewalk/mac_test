import Foundation
import UIKit

class BoogieCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .boogie
    var boogieViewController: BoogieVC
    
    func start() {
        boogieViewController.viewModel = BoogieViewModel(coordinator: self,
                                                         videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.boogieViewController, animated: true)
    }
    
    func presentToComment(videoId: String) {
        let commentCoordinator = CommentViewCoordinator(self.navigationController)
        let commentViewContolloer = commentCoordinator.commentViewController
        commentViewContolloer.viewModel?.videoId = videoId
        self.childCoordinators.append(commentCoordinator)
        commentCoordinator.finishDelegate = self
        commentCoordinator.startComment(videoId: videoId)
    }
    
    func pushToLogin() {
        let loginCoordinator = LoginCoordinator(self.navigationController)
        let loginViewContolloer = loginCoordinator.loginViewController
        self.childCoordinators.append(loginCoordinator)
        loginCoordinator.finishDelegate = self
        loginCoordinator.start()
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
    
    func pushToProfileView(userId: String) {
        let mypageCoordinator = ProfileCoordinator(self.navigationController)
        let mypageViewContorller = mypageCoordinator.profileViewController
        self.childCoordinators.append(mypageCoordinator)
        mypageCoordinator.finishDelegate = self
        //내 프로필일경우
        if userId == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
            mypageCoordinator.start(userId: userId,
                                    profileState: .backButtonMy)
        } else {
            mypageCoordinator.start(userId: userId,
                                    profileState: .other)
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.boogieViewController = BoogieVC()
    }
    
    
}
extension BoogieCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
