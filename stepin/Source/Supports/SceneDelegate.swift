//
//  SceneDelegate.swift
//  stepin
//
//  Created by ikbum on 2023/02/02.
//

import UIKit
import FacebookCore
import AuthenticationServices // 애플 로그인
import FirebaseDynamicLinks
import FirebaseCore
import Sentry
import SDSKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLinks, error in
                
                // Dynamic Link 처리
                print(dynamicLinks)
                // Optional(<FIRDynamicLink: 0x2808c94f0, url [https://exdeeplinkjake.page.link/navigation&ibi=com.jake.sample.ExDeeplink], match type: unique, minimumAppVersion: N/A, match message: (null)>)
            }
        }
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        registerFonts()
        FirebaseApp.configure()

        // 애플로그인
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: UserDefaults.standard.string(forKey: "userIdentifier") ?? "") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("이전에 로그인 성공했으니 홈화면으로 이동")
                break // The Apple ID credential is valid.
            case .revoked, .notFound:
                print("애플 id 인증이 취소되거나 찾을수없음")
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                DispatchQueue.main.async {
//                    self.window?.rootViewController?.showLoginViewController()
                }
            default:
                break
            }
        }
        SentrySDK.start { options in
            options.dsn = "https://bb5856d51c8d4cfb9020a9c8981737a8@o4505317515460608.ingest.sentry.io/4505322750541824"
            //실 배포시에는 0.5정도를 추천한다구 함
            options.tracesSampleRate = 1.0
            // OR if you prefer, determine traces sample rate based on the
            // sampling context
            options.tracesSampler = { context in
                // Don't miss any transactions for VIP users
                if context.customSamplingContext?["vip"] as? Bool == true {
                    return 1.0
                } else {
                    return 0.25 // 25% for everything else
                }
            }
            options.debug = false// Enabled debug when first installing is always helpful
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        self.coordinator = SplashCoordinator(navigationController)
        self.coordinator?.start()
        
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    // facebook
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }


}

