import UIKit
import Foundation
import SnapKit
import Then
import MarqueeLabel

class ProductView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    internal func setData(energy: Int,
                          price: NSDecimalNumber,
                          locales: Locale,
                         image: UIImage) {
//        self.energyLabel.text = "\(energy) energy"
        self.energyImage.setTitle("\(energy)", for: .normal)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locales
        let formattedPrice = formatter.string(from: NSNumber(value: price.doubleValue))

        self.purchaseLabel.text = formattedPrice
        self.productImageView.image = image
    }

    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.layer.borderColor = UIColor.stepinWhite100.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        
        self.addSubviews([ productImageView, energyImage, purchaseButton])
//        energyLabel.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
//        }
        
        energyImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 50))
//            $0.width.equalTo(ScreenUtils.setWidth(value: 55))
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }

        productImageView.snp.makeConstraints {
            $0.top.equalTo(energyImage.snp.bottom).inset(ScreenUtils.setWidth(value: 30))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 25))
            $0.bottom.equalTo(purchaseButton.snp.top).inset(ScreenUtils.setWidth(value: 30))
        }

        purchaseButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 32))
        }
        purchaseButton.addSubview(purchaseLabel)
        purchaseLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 6))
        }

    }
    
//    private let energyLabel = UILabel().then {
//        $0.font = .suitMediumFont(ofSize: 16)
//        $0.textColor = .stepinWhite100
//        $0.textAlignment = .center
//    }
    private let productImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    private let energyImage = UIButton().then {
        $0.setTitle("", for: .normal)
        $0.setImage(ImageLiterals.icEnergy, for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 20)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        $0.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
    }
    
    
    internal let purchaseButton = UIButton().then {
        $0.backgroundColor = .stepinWhite100
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        $0.clipsToBounds = true
    }
    private let purchaseLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.textColor = .stepinBlack100
        $0.font = .ShrikhandRegular(ofSize: 20).italic()
        $0.textAlignment = .center
    }
}
