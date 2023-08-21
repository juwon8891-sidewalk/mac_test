import Foundation
import UIKit
import SwiftSVG
import SnapKit

final class NeonView: UIView {
    var neonHandler: NeonPlayHandler?
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    deinit {
        self.neonHandler = nil
        print("deinit neonView")
    }
    
    func setNeonHandler(neonHandler: NeonPlayHandler) {
        self.neonHandler = neonHandler
        self.neonHandler?.delegate = self
    }
}
extension NeonView: NeonPlayProtocol {
    func getCurrentPlayLayer(layer: CALayer) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.layer.sublayers?.removeAll()
            strongSelf.layer.addSublayer(layer)
            strongSelf.layer.displayIfNeeded()
        }
    }
}
