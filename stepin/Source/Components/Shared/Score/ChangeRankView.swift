import Foundation
import UIKit
import SDSKit
import SnapKit
import Then

final class ChangeRankView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
        self.startArrowAnimation()
    }
    
    func bindRank(myRank: String,
                  expectedRank: String) {
        self.myRankLabel.text = myRank
        self.expectedRankLabel.text = expectedRank
    }
    
    private func startArrowAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.arrowImageView.transform = CGAffineTransform(translationX: 0, y: 5)
        }
    }
    
    private func setLayout() {
        self.addSubviews([topGradientView, expectedRankLabel, arrowImageView, myRankLabel, bottomGradientView])
        
        topGradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalTo(56)
            $0.height.equalTo(2)
        }
        
        expectedRankLabel.snp.makeConstraints {
            $0.top.equalTo(topGradientView.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.top.equalTo(expectedRankLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(24.adjusted)
        }
        
        myRankLabel.snp.makeConstraints {
            $0.top.equalTo(arrowImageView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.top.equalTo(myRankLabel.snp.bottom).offset(2)
            $0.width.equalTo(56)
            $0.height.equalTo(2)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private let topGradientView = UIView().then {
        $0.addGradient(size: .init(width: 56, height: 2),
                       colors: [UIColor.clear.cgColor, UIColor.PrimaryWhiteNormal.cgColor, UIColor.clear.cgColor],
                       startPoint: .centerLeft,
                       endPoint: .centerRight)
    }
    
    private let expectedRankLabel = UILabel().then {
        $0.font = SDSFont.h1.font.withSize(24)
        $0.textColor = .PrimaryWhiteNormal
        $0.text = "-"
    }
    
    private let arrowImageView = UIImageView(image: SDSIcon.icChevronLess).then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let myRankLabel = UILabel().then {
        $0.font = SDSFont.h1.font.withSize(24)
        $0.textColor = .PrimaryWhiteNormal
        $0.text = "-"
    }
    
    private let bottomGradientView = UIView().then {
        $0.addGradient(size: .init(width: 56, height: 2),
                       colors: [UIColor.clear.cgColor, UIColor.PrimaryWhiteNormal.cgColor, UIColor.clear.cgColor],
                       startPoint: .centerLeft,
                       endPoint: .centerRight)
    }
}
