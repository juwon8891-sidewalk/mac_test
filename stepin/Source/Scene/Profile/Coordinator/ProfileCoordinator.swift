import Foundation
import UIKit

class ProfileCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .my
    var profileViewController: ProfileVC
    
    func start() {
        self.profileViewController.profileViewModel = ProfileViewModel(coordinator: self)
        self.navigationController.pushViewController(profileViewController, animated: true)
    }
    
    func start(userId: String,
               profileState: ProfileViewState) {
        self.profileViewController.profileViewModel = ProfileViewModel(coordinator: self)
        self.profileViewController.profileViewModel?.userId = userId
        self.profileViewController.profileViewModel?.profileState = profileState
        self.navigationController.pushViewController(profileViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.profileViewController = ProfileVC()
    }
    
    func popViewController() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToProfileView(imagePath: String) {
        let profileImageViewCoordinator = ProfileImageCoordinator(self.navigationController)
        let profileImageViewController = profileImageViewCoordinator.profileIamgeViewController
        self.childCoordinators.append(profileImageViewCoordinator)
        profileImageViewCoordinator.finishDelegate = self
        profileImageViewCoordinator.start(profilePath: imagePath)
        profileImageViewController.modalPresentationStyle = .overFullScreen
        self.profileViewController.present(profileViewController, animated: true)
    }
    
    func pushToEditProfile(backgroundVideoPath: String) {
        let editProfileCoordinator = EditMyProfileCoordinator(self.navigationController)
        self.childCoordinators.append(editProfileCoordinator)
        editProfileCoordinator.finishDelegate = self
        editProfileCoordinator.start(backgroundVideoPath: backgroundVideoPath)
    }
    
    func pushToSettingView() {
        let settingCoordinator = SettingCoordinator(self.navigationController)
        self.childCoordinators.append(settingCoordinator)
        settingCoordinator.finishDelegate = self
        settingCoordinator.start()
    }
    func pushToNormalVideoView(videoData: [NormalVideoCollectionViewDataSection], pageNum: Int, indexPath: IndexPath) {
        let videoViewCoordinator = NormalViewCoordinator(self.navigationController)
        self.childCoordinators.append(videoViewCoordinator)
        videoViewCoordinator.finishDelegate = self
        videoViewCoordinator.start(videoData: videoData, pageNum: pageNum, type: .myPage, userId: UserDefaults.standard.string(forKey: UserDefaultKey.userId) ?? "", indexPath: indexPath)
    }
    /**
     내 프로필의 팔로우 팔로잉을 들어갈 경우
     */
    func pushToFollowerVC(userid: String) {
        let followCoordinator = ShowFollowerCoordinator(self.navigationController)
        let followerViewController = followCoordinator.showFollowerViewController
        self.childCoordinators.append(followCoordinator)
        followCoordinator.finishDelegate = self
        followCoordinator.start(type: .follower)
        if let myId = UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
            if myId == userid {
                followerViewController.viewModel?.userId = myId
            } else {
                followerViewController.viewModel?.userId = userid
            }
        }
        
    }
    
    func pushToFollowingVC(userid: String) {
        let followCoordinator = ShowFollowerCoordinator(self.navigationController)
        let followingViewContolloer = followCoordinator.showFollowerViewController
        self.childCoordinators.append(followCoordinator)
        followCoordinator.finishDelegate = self
        followCoordinator.start(type: .following)
        if let myId = UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
            if myId == userid {
                followingViewContolloer.viewModel?.userId = myId
            } else {
                followingViewContolloer.viewModel?.userId = userid
            }
        }
    }
    
    func presentToBottomSheet(userId: String,
                              isFollowed: Bool,
                              isBlocked: Bool,
                              isBoosted: Bool) {
        let bottomSheetCoordinator = BottomSheetCoordinator(self.navigationController)
        let bottomSheetViewController = bottomSheetCoordinator.bottomSheetViewController
        self.childCoordinators.append(bottomSheetCoordinator)
        bottomSheetCoordinator.finishDelegate = self
        bottomSheetCoordinator.startData(userId: userId,
                                         videoId: "",
                                         isFollowed: isFollowed,
                                         isBlocked: isBlocked,
                                         isBoosted: isBoosted,
                                         type: .otherPage)
        
    }
}

extension ProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
