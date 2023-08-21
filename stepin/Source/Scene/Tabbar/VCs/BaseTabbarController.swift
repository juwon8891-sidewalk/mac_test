//
//  BaseTabbarController.swift
//  stepin
//
//  Created by ikbum on 2023/02/10.
//

import UIKit

class BaseTabbarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, stepinTabbar.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class stepinTabbar: UITabBar {
        override open func sizeThatFits(_ size: CGSize) -> CGSize {
            super.sizeThatFits(size)
            guard let window = UIWindow.key else {
                return super.sizeThatFits(size)
            }
            var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = window.safeAreaInsets.bottom + 60
            return sizeThatFits
        }
    }

}
