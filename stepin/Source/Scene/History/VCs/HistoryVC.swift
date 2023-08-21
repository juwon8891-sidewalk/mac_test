import UIKit
import Lottie
import SnapKit
import Then
import RealmSwift
import RxSwift
import RxRelay

class HistoryVC: UIViewController {
    
    var viewModel: HistoryViewModel?
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        self.view = historyView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = .PrimaryBlackNormal
//        self.tabBarController?.tabBar.isTranslucent = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.setHistoryCollectionViewLayout()
        self.bindViewModel()
        self.bindCompletion()
        self.addNotification()
    }
    
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppeared: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      calendarView: self.historyView.calendarView,
                                                      navigationView: self.historyView.navigationView,
                                                      storageInfoView: self.historyView.storageInfoView,
                                                      deleteAlertView: self.historyView.deleteAlertView,
                                                      collectionView: self.historyView.collectionView,
                                                      bottomDeleteBar: self.historyView.deleteBottomView),
                                          disposeBag: disposeBag)
        
        output?.setCurrentTitle
            .withUnretained(self)
            .bind(onNext: { (vc, title) in
                self.historyView.navigationView.setTitle(date: title)
            })
            .disposed(by: disposeBag)
        
        output?.isDeleteMode
            .debug()
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                vc.historyView.storageInfoView.selectAllButton.isHidden = !state
                vc.historyView.storageInfoView.deleteButton.isHidden = state
            })
            .disposed(by: disposeBag)
        
        output?.isHiddenBottomDeleteBar
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                vc.historyView.deleteBottomView.isHidden = state
                vc.tabBarController?.tabBar.isHidden = !state
            })
            .disposed(by: disposeBag)
        
        output?.showDeleteAlertView
            .withUnretained(self)
            .bind(onNext: { (vc, cnt) in
                vc.historyView.deleteAlertView.setDeleteLabel(title: "\(cnt)")
                vc.historyView.deleteAlertView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        output?.hideDeleteAlertView
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                DispatchQueue.main.async {
                    vc.historyView.deleteAlertView.isHidden = true
                    vc.historyView.storageInfoView.selectAllButton.isSelected = false
                    vc.historyView.storageInfoView.selectAllButton.isHidden = true
                    vc.historyView.storageInfoView.deleteButton.isHidden = false
                    vc.historyView.deleteBottomView.deleteButton.buttonState = .disabled
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindCompletion() {
        self.historyView.navigationView.titleButtonCompletion = {
            UIView.animate(withDuration: 0.5,
                           delay: 0) {
                self.historyView.calendarView.transform = CGAffineTransform(translationX: 0,
                                                                            y: 405.adjusted)
            }
        }
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUploadComplete),
                                               name: NSNotification.Name("is_video_upload_complete"),
                                               object: nil)
    }
    
    @objc private func didUploadComplete() {
        self.view.makeToast(title: "new_dance_upload_complete_toast_title".localized(),
                            type: .blueCheck)
    }
    
    private func setHistoryCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        historyView.collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    let historyView = HistoryView()

}
