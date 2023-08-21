import UIKit
import SDSKit
import Then
import SnapKit

class PlayNaviationView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([energyBar, searchButton])
        energyBar.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(24.adjusted)
        }
        searchButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.height.equalTo(48.adjusted)
        }
    }
    
    let energyBar = EnergyBar()
    let searchButton = UIButton().then {
        $0.setImage(SDSIcon.icSearch, for: .normal)
    }
}
