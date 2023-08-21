import Foundation
import UIKit

class NormalViewCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .video
    var normalVideoViewController: NormalVideoVC
    
    func start() {
        normalVideoViewController.viewModel = NormalVideoViewModel(coordinator: self,
                                                                   videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.normalVideoViewController, animated: true)
    }
    
    func start(videoData: [NormalVideoCollectionViewDataSection],
               pageNum: Int,
               type: callVideoType,
               userId: String = "",
               danceId: String = "",
               musicId: String = "",
               keyword: String = "",
               indexPath: IndexPath) {
        normalVideoViewController.viewModel = NormalVideoViewModel(coordinator: self,
                                                                   videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        normalVideoViewController.viewModel?.pageNum = pageNum
        normalVideoViewController.viewModel?.normalResult = videoData
        normalVideoViewController.viewModel?.userId = userId
        normalVideoViewController.viewModel?.danceId = danceId
        normalVideoViewController.viewModel?.musicId = musicId
        normalVideoViewController.viewModel?.keyWord = keyword
        normalVideoViewController.viewModel?.indexPath = indexPath
        self.navigationController.pushViewController(self.normalVideoViewController, animated: true)
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
    
    func pushToLogin() {
        let loginCoordinator = LoginCoordinator(self.navigationController)
        let loginViewContolloer = loginCoordinator.loginViewController
        self.childCoordinators.append(loginCoordinator)
        loginCoordinator.finishDelegate = self
        loginCoordinator.start()
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func popToMypage() {
        DispatchQueue.main.async {
            self.navigationController.dismiss(animated: true) {
                self.navigationController.popViewController(animated: true)
            }
        }
    }
    
    func pushToProfileView(userId: String) {
        //내 프로필일경우
        if userId == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
            let mypageCoordinator = ProfileCoordinator(self.navigationController)
            let mypageViewContorller = mypageCoordinator.profileViewController
            self.childCoordinators.append(mypageCoordinator)
            mypageCoordinator.finishDelegate = self
            mypageCoordinator.start()
        } else {
//            let otherMypageCoordinator = OtherMyPageCoordinator(self.navigationController)
//            let otherMypageViewContorller = otherMypageCoordinator.otherMyPageViewController
//            self.childCoordinators.append(otherMypageCoordinator)
//            otherMypageCoordinator.finishDelegate = self
//            otherMypageCoordinator.start(userId: userId)
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.normalVideoViewController = NormalVideoVC()
    }
    
    
}
extension NormalViewCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
