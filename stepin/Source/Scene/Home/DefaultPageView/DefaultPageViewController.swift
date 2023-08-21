import Foundation
import RxSwift

class DefaultPageViewController: UIPageViewController, UIPageViewControllerDataSource, DefaultPageViewControllProtocol{
    private var disposeBag = DisposeBag()
    private var handler = DefaultPageViewHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        bindHandler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handler.viewDidAppeared()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        handler.viewWillDisappear()
    }
    
    private func bindHandler() {
        handler.viewItemListResultRelay.withUnretained(self).bind(onNext: { (vc, _) in
            
            })
            .disposed(by: disposeBag)
    }
    
    // 페이지를 앞으로 넘겼을 때
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewController
    }
    
    /// 페이지를 다음으로 넘겼을 때
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewController
    }
    
    func setLayout() {
        self.dataSource = self
        self.setViewControllers(self.handler.viewList, direction: .forward, animated: true)
    }
}

protocol DefaultPageViewControllProtocol {
    func setLayout()
}
