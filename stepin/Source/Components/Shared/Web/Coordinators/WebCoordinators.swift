import Foundation
import UIKit

class WebCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .web
    var webViewController: WebVC
    
    func start() {
        self.navigationController.present(webViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.webViewController = WebVC(type: .none, url: "")
    }
    
    init(_ navigationController: UINavigationController, url: String, type: webViewType) {
        self.navigationController = navigationController
        self.webViewController = WebVC(type: type,
                                       url: url)
    }

}

