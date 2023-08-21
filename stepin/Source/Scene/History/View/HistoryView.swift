import Foundation
import UIKit
import SDSKit
import SnapKit
import Then

class HistoryView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .init(x: .zero,
                                y: .zero,
                                width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.height))
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([storageInfoView, navigationView, devideView, collectionView, calendarView, deleteAlertView, deleteBottomView])
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60.adjusted)
        }
        
        storageInfoView.snp.makeConstraints {
            $0.top.equalTo(devideView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(55.adjusted)
        }
        
        devideView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(storageInfoView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(405.adjusted)
            $0.bottom.equalTo(self.snp.top)
        }
        deleteAlertView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        deleteAlertView.isHidden = true
        
        guard let window = UIWindow.key else {return}
        deleteBottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(window.safeAreaInsets.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        deleteBottomView.isHidden = true
    }
    
    let storageInfoView = StorageInfoView()
    let navigationView = HistoryNavigationView()
    let devideView = UIView().then {
        $0.backgroundColor = .PrimaryWhiteDisabled
    }
    let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .PrimaryBlackNormal
        $0.alwaysBounceVertical = true
    }    
    var calendarView = CalendarView()
    var deleteAlertView = DeleteDanceAlertView()
    var deleteBottomView = VideoDeleteBottomBar()
    
}
