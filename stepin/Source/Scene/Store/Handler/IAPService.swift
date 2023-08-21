import StoreKit
import RxSwift
import Sentry

typealias ProductsRequestCompletion = (_ success: Bool, _ products: [SKProduct]?) -> Void

protocol IAPServiceType {
    var canMakePayments: Bool { get }
    
    func getProducts(completion: @escaping ProductsRequestCompletion)
    func buyProduct(_ product: SKProduct)
    func isProductPurchased(_ productID: String) -> Bool
    func restorePurchases()
}

final class IAPService: NSObject, IAPServiceType {
    private let productIDs: Set<String>
    private var purchasedProductIDs: Set<String>
    private var productsRequest: SKProductsRequest?
    private var productsCompletion: ProductsRequestCompletion?
    
    private var paymentRepository = PaymentRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var disposeBag = DisposeBag()
    
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    init(productIDs: Set<String>) {
        self.productIDs = productIDs
        print(productIDs)
        self.purchasedProductIDs = productIDs
            .filter { UserDefaults.standard.bool(forKey: $0) == true }
        
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func getProducts(completion: @escaping ProductsRequestCompletion) {
        self.productsRequest?.cancel()
        self.productsCompletion = completion
        self.productsRequest = SKProductsRequest(productIdentifiers: self.productIDs)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    func buyProduct(_ product: SKProduct) {
        SKPaymentQueue.default().add(SKPayment(product: product))
//        print(SKPaymentQueue.default().transactionObservers.debugDescription)
    }
    func isProductPurchased(_ productID: String) -> Bool {
        self.purchasedProductIDs.contains(productID)
    }
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPService: SKProductsRequestDelegate {
    // didReceive
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        self.productsCompletion?(true, products)
        self.clearRequestAndHandler()
        
        products.forEach { print("Found product: \($0.productIdentifier) \($0.localizedTitle) \($0.price.floatValue)") }
    }
    
    // failed
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("unknown")
        print("Erorr: \(error.localizedDescription)")
        self.productsCompletion?(false, nil)
        self.clearRequestAndHandler()
        
    }
    
    private func clearRequestAndHandler() {
        self.productsRequest = nil
        self.productsCompletion = nil
    }
    
}


extension IAPService: SKPaymentTransactionObserver {
    func getRecipe() -> String {
        // Get the receipt if it's available.
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                let receiptString = receiptData.base64EncodedString(options: [])
                print(receiptString)
                NotificationCenter.default.post(
                    name: .lastRecipe,
                    object: receiptString
                )
                return receiptString
                // Read receiptData.
            }
            catch {
                SentrySDK.capture(error: error)
                print("Couldn't read receipt data with error: " + error.localizedDescription)
            }
        }
        return ""
    }
    
    func postPaymentServerToRecipe(recipe: String, state: SKPaymentTransaction) {
        self.authRepository.postRefreshToken()
            .flatMap{ [weak self] _ in (self?.paymentRepository.postReceiptsToVerification(receipt: recipe))! }
            .subscribe(onNext: { [weak self] result in
                if result.data.status == true { //success
                    print(result)
                    self?.deliverPurchaseNotificationFor(id: state.original?.payment.productIdentifier)
                    SKPaymentQueue.default().finishTransaction(state)
                } else {
                    print("결제 실패 예외처리")
                }
                NotificationCenter.default.post(
                    name: .didVerificateReceiptEnd,
                    object: nil
                )
            })
            .disposed(by: disposeBag)
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        queue.transactions.forEach {
            switch $0.transactionState {
            case .purchased:
                //transactions의 원소들을 불러와서 상태를 보고
                //만약 결제가 완료 되었는데도 transactions에 유지 되면,,, 더블체크 필요
                //아니면 Date로 5분이내 해서 걔내만 처리
                //레시피 받아서 보내고, 아무튼 가장 최신의(5분이내의 가장 빠른거)
                NotificationCenter.default.post(
                    name: .didPurchaseEnd,
                    object: description
                )
                //결제 완료시 영수증 호출 및 영수증 데이터에 대해 stepin payment서버로 리퀘스트를 보내줌
                let recipeData = getRecipe()
                NotificationCenter.default.post(
                    name: .didStartVerificateReceipt,
                    object: description
                )
                postPaymentServerToRecipe(recipe: recipeData, state: $0)
                print("completed transaction")
            case .failed:
                if let transactionError = $0.error as NSError?,
                   let description = $0.error?.localizedDescription,
                   transactionError.code != SKError.paymentCancelled.rawValue {
                    print("Transaction erorr: \(description)")
                    NotificationCenter.default.post(
                        name: .lastRecipe,
                        object: description
                    )
                }
                NotificationCenter.default.post(
                    name: .didPurchaseEnd,
                    object: description
                )
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                print("failed transaction")
                self.deliverPurchaseNotificationFor(id: $0.original?.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction($0)
            case .deferred:
                print("deferred")
            case .purchasing:
                print("purchasing")
            default:
                break
            }
        }
    }
    
    private func deliverPurchaseNotificationFor(id: String?) {
        guard let id = id else { return }
        
        self.purchasedProductIDs.insert(id)
        UserDefaults.standard.set(true, forKey: id)
        NotificationCenter.default.post(
            name: .iapServicePurchaseNotification,
            object: id
        )
    }
}
