import UIKit

struct AppFontName {
    static let thin = "SUIT-Thin"
    static let light = "SUIT-Light"
    static let regular = "SUIT-Regular"
    static let medium = "SUIT-Medium"
    static let bold = "SUIT-Bold"
    static let semiBold = "SUIT-SemiBold"
    static let extraBold = "SUIT-ExtraBold"
    static let extraLight = "SUIT-ExtraLight"
    static let heavy = "SUIT-Heavy"
}

extension UIFont {
    
    @objc class func suitThinFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.thin, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitLightFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.light, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitRegularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitMediumFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.medium, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitSemiBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.semiBold, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitExtraBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.extraBold, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitExtraLigthFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.extraLight, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func suitHeavyFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.heavy, size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func ShrikhandRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Shrikhand-Regular", size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func CHONBUKL(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "CHONBUKL", size: ScreenUtils.setWidth(value: size))!
    }
    
    @objc class func largeTitle() -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: 36))!
    }
    
    @objc class func button() -> UIFont {
        return UIFont(name: AppFontName.semiBold, size: ScreenUtils.setWidth(value: 18))!
    }
    
    @objc class func callout() -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: 14))!
    }
    
    @objc class func title01() -> UIFont {
        return UIFont(name: AppFontName.semiBold, size: ScreenUtils.setWidth(value: 28))!
    }
    
    @objc class func title02() -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: 24))!
    }
    
    @objc class func title03() -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: 22))!
    }
    
    @objc class func headline01() -> UIFont {
        return UIFont(name: AppFontName.extraBold, size: ScreenUtils.setWidth(value: 20))!
    }
    
    @objc class func headline02() -> UIFont {
        return UIFont(name: AppFontName.extraBold, size: ScreenUtils.setWidth(value: 18))!
    }
    
    @objc class func body01() -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: 18))!
    }
    
    @objc class func body02() -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: 16))!
    }
    
    @objc class func caption01() -> UIFont {
        return UIFont(name: AppFontName.regular, size: ScreenUtils.setWidth(value: 12))!
    }
    
    @objc class func caption02() -> UIFont {
        return UIFont(name: AppFontName.light, size: ScreenUtils.setWidth(value: 12))!
    }
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
