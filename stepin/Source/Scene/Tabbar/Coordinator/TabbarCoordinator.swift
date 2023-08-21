import UIKit
import Foundation
import SnapKit
import SDSKit
import Kingfisher

final class TabbarCoordinator: NSObject, Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType { .tab }
    var tabBarController: BaseTabbarController
    let defaultImage = ImageLiterals.icMyDefault.resized(to: .init(width: ScreenUtils.setWidth(value: 20),
                                                                   height: ScreenUtils.setWidth(value: 20))).withRenderingMode(.alwaysOriginal)
    let unSelectedImage = ImageLiterals.icMyDefaultUnselected.resized(to: .init(width: ScreenUtils.setWidth(value: 20),
                                                                              height: ScreenUtils.setWidth(value: 20))).withRenderingMode(.alwaysOriginal)
    
    var controllers: [UINavigationController] = []

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = BaseTabbarController()
        navigationController.setNavigationBarHidden(true, animated: true)
        super.init()
    }
    func start() {
        let pages: [TabBarPage] = TabBarPage.allCases
        controllers = pages.map({
            self.createTabNavigationController(of: $0)
        })
        self.configureTabBarController(with: controllers)
    }
    
    
              
    func currentPage() -> TabBarPage? {
        TabBarPage(index: self.tabBarController.selectedIndex)
    }
    
    func selectPage(_ page: TabBarPage) {
        self.tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage(index: index) else { return }
        self.tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    func createTabNavigationController(of page: TabBarPage) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        tabNavigationController.setNavigationBarHidden(false, animated: false)
        tabNavigationController.tabBarItem = self.configureTabBarItem(of: page, image: defaultImage, selectedImage: unSelectedImage)
        self.startTabCoordinator(of: page, to: tabNavigationController, loginSatus: UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus))

        return tabNavigationController
    }
    
    @objc func chageImage(_ sender: NSNotification) {
    }
    
    private func configureTabBarItem(of page: TabBarPage, image: UIImage, selectedImage: UIImage) -> UITabBarItem {
        let appearance = UITabBarItem.appearance()
        appearance.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.suitRegularFont(ofSize: 12)],
                                          for: .normal)
        switch page {
        case .home:
            let item = UITabBarItem(
                title: "tabbar_home_title".localized(),
                image: SDSIcon.icHomeInactive,
                selectedImage: SDSIcon.icHomeActive
            )
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: ScreenUtils.setWidth(value: -5))
            item.tag = page.pageOrderNumber()
            
            return item
        case .boogie:
            let item = UITabBarItem(
                title: "tabbar_boogie_title".localized(),
                image: SDSIcon.icBoogieInactive,
                selectedImage: SDSIcon.icBoogieActive
            )
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: ScreenUtils.setWidth(value: -5))
            item.tag = page.pageOrderNumber()
            return item
        case .play:
            let item = UITabBarItem(
                title: "tabbar_play_title".localized(),
                image: SDSIcon.icPlayInactive,
                selectedImage: SDSIcon.icPlayActive
            )
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: ScreenUtils.setWidth(value: -5))
            item.tag = page.pageOrderNumber()
            return item
        case .history:
            let item = UITabBarItem(
                title: "tabbar_history_title".localized(),
                image: SDSIcon.icHistoryInactive,
                selectedImage: SDSIcon.icHistoryActive
            )
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: ScreenUtils.setWidth(value: -5))
            item.tag = page.pageOrderNumber()
            return item
        case .myPage:
            let item = UITabBarItem(
                title: "tabbar_my_title".localized(),
                image: SDSIcon.icMyProfileInactive,
                selectedImage: SDSIcon.icMyProfileActive)
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: ScreenUtils.setWidth(value: -5))
            item.imageInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
            item.tag = page.pageOrderNumber()
            return item
        }
    }
    
    private func configureTabBarController(with tabViewControllers: [UIViewController]) {
        self.tabBarController.setViewControllers(tabViewControllers, animated: true)
        self.tabBarController.selectedIndex = TabBarPage.home.pageOrderNumber()
        self.tabBarController.view.backgroundColor = .stepinBlack100
        self.tabBarController.tabBar.backgroundColor = .stepinBlack100
        self.tabBarController.viewSafeAreaInsetsDidChange()
        self.tabBarController.tabBar.tintColor = .white
        self.tabBarController.tabBar.unselectedItemTintColor = .stepinWhite40
        self.tabBarController.tabBar.sizeThatFits(.zero)
        
        let topLineView = UIView()
        topLineView.backgroundColor = .stepinWhite40
        
        self.tabBarController.tabBar.addSubview(topLineView)
        topLineView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-1)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        self.tabBarController.tabBar.layer.borderColor = UIColor.stepinWhite40.cgColor
        self.navigationController.pushViewController(self.tabBarController, animated: true)

    }
    
    
    
    private func startTabCoordinator(of page: TabBarPage, to tabNavigationController: UINavigationController, loginSatus: Bool) {
        if loginSatus {
            switch page {
            case .home:
                let homeCoordinator = HomeCoordinator(tabNavigationController)
                homeCoordinator.finishDelegate = self
                self.childCoordinators.append(homeCoordinator)
                homeCoordinator.start()
            case .boogie:
                let boogieCoordinator = BoogieCoordinator(tabNavigationController)
                boogieCoordinator.finishDelegate = self
                self.childCoordinators.append(boogieCoordinator)
                boogieCoordinator.start()
            case .play:
                let playCoordinator = PlayDanceViewCoordinator(tabNavigationController)
                playCoordinator.finishDelegate = self
                self.childCoordinators.append(playCoordinator)
                playCoordinator.start()
            case .history:
                let historyCoordinator = HistoryCoordinator(tabNavigationController)
                historyCoordinator.finishDelegate = self
                self.childCoordinators.append(historyCoordinator)
                historyCoordinator.start()
            case .myPage:
                let mypageCoordinator = ProfileCoordinator(tabNavigationController)
                mypageCoordinator.finishDelegate = self
                self.childCoordinators.append(mypageCoordinator)
                mypageCoordinator.start(userId: UserDefaults.userId,
                                        profileState: .my)
            }
        } else {
            switch page {
            case .home:
                let homeCoordinator = HomeCoordinator(tabNavigationController)
                homeCoordinator.finishDelegate = self
                self.childCoordinators.append(homeCoordinator)
                homeCoordinator.start()
            case .boogie:
                let boogieCoordinator = BoogieCoordinator(tabNavigationController)
                boogieCoordinator.finishDelegate = self
                self.childCoordinators.append(boogieCoordinator)
                boogieCoordinator.start()
            case .play:
                let induceLoginCoordinator = InduceLoginCoordinator(tabNavigationController)
                induceLoginCoordinator.finishDelegate = self
                self.childCoordinators.append(induceLoginCoordinator)
                induceLoginCoordinator.start(viewType: .play)
            case .history:
                let induceLoginCoordinator = InduceLoginCoordinator(tabNavigationController)
                induceLoginCoordinator.finishDelegate = self
                self.childCoordinators.append(induceLoginCoordinator)
                induceLoginCoordinator.start(viewType: .history)
            case .myPage:
                let induceLoginCoordinator = InduceLoginCoordinator(tabNavigationController)
                induceLoginCoordinator.finishDelegate = self
                self.childCoordinators.append(induceLoginCoordinator)
                induceLoginCoordinator.start(viewType: .profile)
            }
        }
    }
    
}

extension TabbarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        if childCoordinator.type == .home {
            navigationController.viewControllers.removeAll()
        } else if childCoordinator.type == .my {
            self.navigationController.viewControllers.removeAll()
            self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        }
    }
    
    func showScreenAccordingToLoginStatus(boolValue: Bool) {
        if boolValue {
            //            pushToBirthdayView()
            print("A")
        } else {
            print("B")
            //            pushToEmailView()
        }
    }
}

