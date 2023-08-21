import Foundation
import UIKit

class ProfileImageCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .profileImageView
    var profileIamgeViewController: ProfileImageVC
    
    func start() {
        self.navigationController.pushViewController(profileIamgeViewController, animated: true)
    }
    
    func start(profilePath: String) {
        self.profileIamgeViewController.setProfileImage(imagePath: profilePath)
    }
  
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.profileIamgeViewController = ProfileImageVC()
    }
    
}
