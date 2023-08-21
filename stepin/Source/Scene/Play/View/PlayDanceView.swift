import UIKit
import SDSKit
import SnapKit
import Then

final class PlayDanceView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
        self.setHotDanceButtonSelected()
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.addSubviews([backgroundImageView, tableView, hotDanceButton, myDanceButton, bottomLineView, playNavigationView])
        backgroundImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        playNavigationView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60.adjusted)
        }
        hotDanceButton.snp.makeConstraints {
            $0.top.equalTo(self.playNavigationView.snp.bottom).offset(38.adjusted)
            $0.leading.equalToSuperview().offset(16.adjusted)
        }
        myDanceButton.snp.makeConstraints {
            $0.top.equalTo(self.hotDanceButton.snp.top)
            $0.leading.equalTo(hotDanceButton.snp.trailing).offset(40.adjusted)
        }
        bottomLineView.snp.makeConstraints {
            $0.top.equalTo(self.hotDanceButton.snp.bottom).offset(20.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(bottomLineView.snp.bottom)
            $0.bottom.equalToSuperview().inset(self.getTabbarHeight())
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setHotDanceButtonSelected() {
        self.hotDanceButton.isSelected = true
    }
    
    private let backgroundImageView = UIImageView(image: UIImage(named: "playBackground"))
    
    let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.estimatedRowHeight = 80.adjusted
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.contentInsetAdjustmentBehavior = .never
    }
    let hotDanceButton = UIButton().then {
        $0.titleLabel?.font = SDSFont.h1.font
        $0.setTitleColor(.PrimaryWhiteAlternative, for: .normal)
        $0.setTitleColor(.PrimaryWhiteNormal, for: .selected)
        $0.setTitle("play_game_hot_dance_tab_title".localized(), for: .normal)
    }
    let myDanceButton = UIButton().then {
        $0.titleLabel?.font = SDSFont.h2.font
        $0.setTitleColor(.PrimaryWhiteAlternative, for: .normal)
        $0.setTitleColor(.PrimaryWhiteNormal, for: .selected)
        $0.setTitle("play_game_my_dance_tab_title".localized(), for: .normal)
    }
    let bottomLineView = UIView().then {
        $0.backgroundColor = .PrimaryWhiteDisabled
    }
    let playNavigationView = PlayNaviationView()
    
}
