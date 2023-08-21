//
//  ABProgressIndicator.swift
//  Pods
//
//  Created by Oscar J. Irun on 2/12/16.
//
//

import UIKit

class ABProgressIndicator: UIView {
    
//    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let indicatorView = UIView(frame: CGRect(x: frame.midX,
                                                 y: 0,
                                                 width: 4,
                                                 height: ScreenUtils.setWidth(value: 32)))
        indicatorView.backgroundColor = .stepinWhite100
        indicatorView.layer.cornerRadius = ScreenUtils.setWidth(value: 4)
        indicatorView.drawShadow(color: .PrimaryBlackHeavy,
                                 opacity: 0.7,
                                 offset: .init(width: 0, height: 0),
                                 radius: 0.3)
        self.addSubview(indicatorView)
        
//        let image = ImageLiterals.icCurrentVideoLocate
//        imageView.frame = self.bounds
//        imageView.image = image
//        imageView.contentMode = UIView.ContentMode.scaleToFill
//        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        imageView.frame = self.bounds
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = CGRect(x: -self.frame.size.width / 2,
                           y: 0,
                           width: self.frame.size.width * 2,
                           height: self.frame.size.height)
        if frame.contains(point){
            return self
        }else{
            return nil
        }
    }
}
