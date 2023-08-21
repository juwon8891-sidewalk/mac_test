import Foundation
import RxCocoa
import RxSwift
import RealmSwift
import RxDataSources
import SDSKit

enum AppstoreOpenError: Error {
    case invalidAppStoreURL
    case cantOpenAppStoreURL
}

final class SplashViewModel: NSObject {
    let tokenUtil = TokenUtils()
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String else {return nil}

        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }
    
    private var appVersion: String = ""
    private var appLink: String = ""
    
    var coordinator : SplashCoordinator?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var updateRelay = PublishRelay<Void>()
    
    private var disposeBag: DisposeBag?
    
    
    init(coordinator: SplashCoordinator) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let alertView: SDSAlertView
    }
    
    struct Output {
        var didNeedUpdate = PublishRelay<Void>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.disposeBag = disposeBag
        self.getVersionData(disposeBag: disposeBag)
        
        input.alertView.okButtonTapCompletion = {
            self.openAppStore(urlStr: self.appLink)
        }
        
        input.alertView.cancelButtonTapCompletion = {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
        
        updateRelay
            .withUnretained(self)
            .bind(onNext: { _ in
                DispatchQueue.main.async {
                    input.alertView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func getVersionData(disposeBag: DisposeBag) {
        self.authRepository.getVerificationVersion()
            .withUnretained(self)
            .subscribe(onNext: { (viewModel, data) in
                self.appVersion = data.data.version
                self.appLink = data.data.versionPath
                self.checkAppVersion(version: data.data.version)
            })
            .disposed(by: disposeBag)
    }
    
    func tokenUpdate(disposeBag: DisposeBag) {
        self.authRepository.postForceRefreshToken()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                //성공시 뷰 이동
                DispatchQueue.main.async {
                    self.coordinator?.pushToTabbar()
                }
            }, onError: { _ in
                //실패 시 로그아웃 상태로 만들고 뷰 이동
                self.removeUserInfo()
                DispatchQueue.main.async {
                    self.coordinator?.pushToTabbar()
                }
            })
            .disposed(by: disposeBag)
    }

    private func removeUserInfo() {
        self.tokenUtil.delete(UserDefaultKey.accessToken)
        self.tokenUtil.delete(UserDefaultKey.refreshToken)
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.name)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.identifierName)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.userId)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.profileUrl)
        UserDefaults.standard.set(false, forKey: UserDefaultKey.LoginStatus)
    }

    
    func checkAppVersion(version: String) {
        let versionArr = version.split(separator: ".")
        let currentVersionArr = (self.version ?? "0.0.0").split(separator: ".")
        
        var isVersionMatched = true
        
        // Major version matched
        if(versionArr[0] != currentVersionArr[0]) {
            isVersionMatched = false
        }
        else{
            if(versionArr[1] != currentVersionArr[1]){
                isVersionMatched = false
            }
            else{
                if(Int(currentVersionArr[2])! < Int(versionArr[2])!){
                    isVersionMatched = false
                }
            }
        }
        
        
        
        print(version, self.version)
        sleep(1)
        if !isVersionMatched {
            self.updateRelay.accept(())
        } else {
            //버전이 올바를 때
            //로그인된 상태라면 토큰 업데이트를 진행하고 이동
            if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                self.tokenUpdate(disposeBag: self.disposeBag!)
            } else { //로그인이 되지 않은 상태라면, 바로 홈으로 이동
                DispatchQueue.main.async {
                    self.coordinator?.pushToTabbar()
                }
            }
        }
    }
    
    func openAppStore(urlStr: String) -> Result<Void, AppstoreOpenError> {
        guard let url = URL(string: urlStr) else {
            print("invalid app store url")
            return .failure(.invalidAppStoreURL)
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return .success(())
        } else {
            print("can't open app store url")
            return .failure(.cantOpenAppStoreURL)
        }
    }
}
