import UIKit
import SnapKit
import Then
import RxSwift
import Lottie

class StoreVC: UIViewController {
    var viewModel: StoreViewModel?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.bindViewModel()
        self.initNoti()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.energyBar.refreshEnergyBar()
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(energy8View: self.energy8View,
                                                      energy18View: self.energy18View,
                                                      energy49View: self.energy49View,
                                                      energy105View: self.energy105View,
                                                      didBackButtonTapped: self.dismissButton.rx.tap.asObservable()),
                                          disposeBag: disposeBag)
    }
    
    private func initNoti() {
        //영수증 검증 실패 했을때 알림
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(makeAlert(_:)),
            name: .makeAlert,
            object: nil
        )
        //검증 성공시 알림
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(makeCorrectAlert(_:)),
            name: .makeAvalibleAlert,
            object: nil
        )

        //페이먼트 리스트 로드 완료
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didStopLoadingView),
            name: .didLoadPaymentList,
            object: nil)
        
        //구매 프로세스 시작
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didPlayLoadingView),
            name: .didStartPurchaseProcess,
            object: nil)
        
        //구매 프로세스 완료
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didStopLoadingView),
            name: .didPurchaseEnd,
            object: nil)
        
        //검증 프로세스 시작
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didPlayLoadingView),
            name: .didStartPurchaseProcess,
            object: nil)
        
        //검증 프로세스 완료
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didStopLoadingView),
            name: .didVerificateReceiptEnd,
            object: nil)
    }
    
    @objc private func restore() {
        MyProducts.iapService.restorePurchases()
    }
    
    
    @objc private func makeAlert(_ notification: Notification) {
        var alert = UIAlertController(title: "Error", message: "Payment receipt proof failed.", preferredStyle: .alert)
        var okAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(okAction)
        self.present(alert, animated: true)
        print("레시피 증명 불가")
    }
    
    
    @objc private func makeCorrectAlert(_ notification: Notification) {
        print("검증 성공")
//        var alert = UIAlertController(title: "검증완료", message: "레시피 검증 완료", preferredStyle: .alert)
//        var okAction = UIAlertAction(title: "확인", style: .cancel)
//        alert.addAction(okAction)
//        self.present(alert, animated: true)
//        print("레시피 검증 완료")
    }
    
    @objc private func didStopLoadingView() {
        self.energyBar.refreshEnergyBar()
        DispatchQueue.main.async {
            self.loadingView.stop()
            self.loadingBackgroundView.isHidden = true
        }
    }
    
    @objc private func didPlayLoadingView() {
        DispatchQueue.main.async {
            self.loadingBackgroundView.isHidden = false
            self.loadingView.loopMode = .loop
            self.loadingView.play()
        }
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([dismissButton, energyBar, titleLabel, energy8View, energy18View, energy49View, energy105View, loadingBackgroundView])
        
        self.dismissButton.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.energyBar.snp.makeConstraints {
            $0.centerY.equalTo(self.dismissButton)
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
//            $0.width.equalTo(ScreenUtils.setWidth(value: 116))
            $0.height.equalTo(ScreenUtils.setWidth(value: 23))
        }
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(energyBar.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
        }
        energy8View.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 164))
            $0.height.equalTo(ScreenUtils.setWidth(value: 216))
        }
        energy18View.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 164))
            $0.height.equalTo(ScreenUtils.setWidth(value: 216))
        }
        energy49View.snp.makeConstraints {
            $0.top.equalTo(self.energy8View.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 164))
            $0.height.equalTo(ScreenUtils.setWidth(value: 216))
        }
        energy105View.snp.makeConstraints {
            $0.top.equalTo(energy18View.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 164))
            $0.height.equalTo(ScreenUtils.setWidth(value: 216))
        }
        loadingBackgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        loadingBackgroundView.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 100))
        }
        loadingView.loopMode = .loop
        loadingView.play()
    }
    
    private let dismissButton = UIButton().then {
        $0.setImage(ImageLiterals.icWhiteX, for: .normal)
    }
    private let energyBar = EnergyBar()
    private let titleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
        $0.text = "store_title_text".localized()
    }
    private var loadingBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack50
    }
    private var loadingView = LottieAnimationView(name: "loading")
    private let energy8View = ProductView()
    private let energy18View = ProductView()
    private let energy49View = ProductView()
    private let energy105View = ProductView()
    
}
