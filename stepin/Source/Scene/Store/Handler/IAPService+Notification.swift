import Foundation

extension Notification.Name {
    static let iapServicePurchaseNotification = Notification.Name("IAPServicePurchaseNotification")
    static let makeAlert = Notification.Name("makeAlert")
    static let makeAvalibleAlert = Notification.Name("makeCorrectAlert")
    static let lastRecipe = Notification.Name("lastRecipe")
    
    static let didLoadPaymentList = Notification.Name("didLoadPaymentList")
    static let didStartPurchaseProcess = Notification.Name("didStartPurchaseProcess")
    static let didPurchaseEnd = Notification.Name("didPurchaseEnd")
    static let didStartVerificateReceipt = Notification.Name("didStartVerificateReceipt")
    static let didVerificateReceiptEnd = Notification.Name("didVerificateReceiptEnd")
    
    static let didDisposeVideo = Notification.Name("didDisposeVideo")
    static let didProfileVideoScrolled = Notification.Name("didProfileVideoScrolled")
    
    static let didLinkCopyed = Notification.Name("didLinkCopyed")
    static let didReportButtonTapped = Notification.Name("didReportButtonTapped")
    static let didSaveVideoStart = Notification.Name("didSaveVideoStart")
    static let didDeleteVideo = Notification.Name("didDeleteVideo")
    static let chageProfileURL = Notification.Name("chageProfileURL")
    static let didStepinPlayButtonTapped = Notification.Name("didStepinPlayButtonTapped")
    static let textView = Notification.Name("textView")
    static let showLoading = Notification.Name("showLoaing")
    static let hideLoading = Notification.Name("hideLoading")
    
    static let SSF_CurrentDanceId = Notification.Name("SSF_CurrentDanceId")
    static let videoPermissionDenined = Notification.Name("videoPermissionDenined")
}
