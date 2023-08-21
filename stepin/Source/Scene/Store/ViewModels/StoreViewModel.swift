import Foundation
import RxCocoa
import RxSwift
import StoreKit
import SwiftPublicIP
import SystemConfiguration


final class StoreViewModel {
    weak var coordinator: StoreViewCoordinators?
    private var signUpRepository: AuthRepository?
    private var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var paymentRepository = PaymentRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())

    private var products = [SKProduct]()
    private var sortProducts = [SKProduct]()
    
    struct Input {
        let energy8View: ProductView
        let energy18View: ProductView
        let energy49View: ProductView
        let energy105View: ProductView
        let didBackButtonTapped: Observable<Void>
    }
    
    struct Output {
    }
    
    init(coordinator: StoreViewCoordinators) {
        self.coordinator = coordinator
    }
    
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.energy8View.purchaseButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(
                    name: .didStartPurchaseProcess,
                    object: nil
                )
                MyProducts.iapService.buyProduct(self.sortProducts[0])
            })
            .disposed(by: disposeBag)
        
        input.energy18View.purchaseButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(
                    name: .didStartPurchaseProcess,
                    object: nil
                )
                MyProducts.iapService.buyProduct(self.sortProducts[1])
            })
            .disposed(by: disposeBag)
        
        input.energy49View.purchaseButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(
                    name: .didStartPurchaseProcess,
                    object: nil
                )
                MyProducts.iapService.buyProduct(self.sortProducts[2])
            })
            .disposed(by: disposeBag)
        
        input.energy105View.purchaseButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(
                    name: .didStartPurchaseProcess,
                    object: nil
                )
                MyProducts.iapService.buyProduct(self.sortProducts[3])
            })
            .disposed(by: disposeBag)
        
        input.didBackButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        getProductList(input: input, disposeBag: disposeBag)
        initNoti()
        
        return output
    }
    
    private func initNoti() {
        //구매 프로세스
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseNoti(_:)),
            name: .iapServicePurchaseNotification,
            object: nil
        )
    }
    
    @objc private func handlePurchaseNoti(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = self.products.firstIndex(where: { $0.productIdentifier == productID })
        else { return }
    }
    
    private func getProductList(input: Input, disposeBag: DisposeBag) {
        MyProducts.iapService.getProducts { [weak self] success, products in
            print("load products \(products ?? [])")
            
            SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let ip = string {
                    print(ip) // Your IP address
                    self?.paymentRepository.getPaymentServerToProductList(ip: ip) { [weak self] data in
                        print(data)
                        guard let strongSelf = self else { return }
                        if success, let products = products {
                            DispatchQueue.main.async {
                                strongSelf.sortProducts = strongSelf.sortProducts(products) // 가격기준으로 오름차순 정렬한 Product
                                print(strongSelf.sortProducts[0].priceLocale)
                                input.energy8View.setData(energy: data.data.quantityPer1D,
                                                          price: (strongSelf.sortProducts[0].price), locales: (strongSelf.sortProducts[0].priceLocale),
                                                          image: ImageLiterals.icPurchase8)
                                input.energy18View.setData(energy: data.data.quantityPer2D,
                                                           price: (strongSelf.sortProducts[1].price), locales: (strongSelf.sortProducts[1].priceLocale),
                                                          image: ImageLiterals.icPurchase18)
                                input.energy49View.setData(energy: data.data.quantityPer5D,
                                                           price: (strongSelf.sortProducts[2].price), locales: (strongSelf.sortProducts[2].priceLocale),
                                                          image: ImageLiterals.icPurchase49)
                                input.energy105View.setData(energy: data.data.quantityPer10D,
                                                            price: (strongSelf.sortProducts[3].price), locales: (strongSelf.sortProducts[3].priceLocale),
                                                          image: ImageLiterals.icPurchase105)
                                strongSelf.products = products

                                NotificationCenter.default.post(
                                    name: .didLoadPaymentList,
                                    object: nil
                                )
                            }
                        }
                    }
                }
            }
 
        }


   
    }
    
    private func sortProducts(_ products: [SKProduct]) -> [SKProduct] {
        return products.sorted { (product1, product2) -> Bool in
            return product1.price.doubleValue < product2.price.doubleValue
        }
    }

}

