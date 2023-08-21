import Foundation
import UIKit

class ScreenUtils {
    //The size of the physical device
    static let deviceSize = UIScreen.main.bounds
    //아이폰 8기준이 default
    static let heigthScale = UIScreen.main.bounds.height / 667
    static let widthScale = UIScreen.main.bounds.width / 375
    
    static func setWidth(value: CGFloat) -> CGFloat {
        return value * widthScale
    }
    
    static func setHeight(value: CGFloat) -> CGFloat {
        return value * heigthScale
    }
    
    static func setFont(value: CGFloat) -> CGFloat {
        return value * widthScale
    }
    

    //MARK: -Constants
    //값이 고정으로 많이 들어가는 수치들은 유지보수에 대비해 미리 함수를 호출 한 값을 배출 할 수 있도록 만들어 둠
    static let smallImageSize = setHeight(value: 47)
    
    //BackButton
    static let icButtonSize = setHeight(value: 24)
    
    static let topNavigationHeight = setHeight(value: 82)
    
    static let textFieldVertical = setHeight(value: 36)
    
    static let iconHorizontal = setWidth(value: 12)
    static let iconVertical = setHeight(value: 40)
    static let wideViewHorizontal = setWidth(value: 16)

    static let largeButtonHorizontal = setWidth(value: 14)
    static let largeButtonVertical = setHeight(value: 16)
    static let largeButtonHeight = setWidth(value: 48)

    static let mediumButtonHorizontal = setWidth(value: 12)
    static let mediumButtonVertical = setHeight(value: 12)
    static let mediumButtonHeight = setWidth(value: 40)

    static let smallButtonHorizontal = setWidth(value: 10)
    static let smallButtonVertical = setHeight(value: 12)
    static let smallButtonHeight = setWidth(value: 32)
    static let smallButtonWidth = setWidth(value: 80)

    static let errorLabelVertical = setHeight(value: 18)
    
    //inbox
    static let UILabel2LineHeigth = setHeight(value: 36)

}
