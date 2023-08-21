import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift

class EnergyBar: UIView {
    private var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var disposeBag = DisposeBag()
    private var timer: Timer? = nil
    
    
    init(size: CGSize){
        super.init(frame: CGRect(origin: .zero, size: size))
        setLayout()
        getData()
    }
    
    init() {
        super.init(frame: .zero)
        setLayout()
        getData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.addSubviews([energyBackgroundView, addEnergyButton, remainingTimeLabel])
        energyBackgroundView.addArrangeSubViews([energyImageView, energyLabel])
        energyBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(24.adjusted)
        }
        addEnergyButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(energyBackgroundView.snp.trailing).offset(4.adjusted)
            $0.width.height.equalTo(24.adjusted)
        }
        remainingTimeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(addEnergyButton.snp.trailing).offset(4.adjusted)
            $0.trailing.equalToSuperview()
        }
    }
    
    internal func refreshEnergyBar() {
        self.timer?.invalidate()
        self.timer = nil
        self.getData()
    }
    
    private func getData() {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.userRepository.getUserStamina())! }
            .subscribe(onNext: { [weak self] result in
                if(self?.timer != nil) { return }
                print(result, "result")
                self?.setEnergyBar(staminaInfo: result.data.stamina)
            })
            .disposed(by: self.disposeBag)
    }
    
//    private var energyBackgroundView = UIView().then {
//        $0.backgroundColor = .clear
//    }
    private var energyImageView = UIImageView().then{
        $0.image = SDSIcon.icEnergy
    }
    private var energyLabel = UILabel().then {
        $0.font = SDSFont.caption1.font
        $0.textColor = .PrimaryWhiteNormal
    }
    internal var addEnergyButton = UIButton().then {
        $0.setBackgroundImage(SDSIcon.icEnergyCharge, for: .normal)
    }
    private var remainingTimeLabel = UILabel().then {
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteAlternative
    }
    
    private var energyBackgroundView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 4
    }
    
    private var staminaInfo: Stamina?
    private func setEnergyBar(staminaInfo: Stamina){
        self.staminaInfo = staminaInfo
        if(staminaInfo.onFree){
            DispatchQueue.main.async {
//                self.energyBackgroundView.image = ImageLiterals.onFreeBackground
                self.energyImageView.image = SDSIcon.icEnergyMax
                self.energyLabel.textColor = .SecondaryPinkHeavy
                self.addEnergyButton.isHidden = true
                self.remainingTimeLabel.isHidden = true
            }
            startOnFreeEnergyTimer(createdAt: staminaInfo.createdAt)
        }
        else{
            DispatchQueue.main.async {
//                self.energyBackgroundView.image = nil
                self.energyImageView.image = SDSIcon.icEnergy
                self.energyLabel.textColor = .PrimaryWhiteNormal
                self.addEnergyButton.isHidden = false
                self.remainingTimeLabel.isHidden = false
            }
            
            startEnergyTimer()
        }
    }
    
    var createdAtDate: Date?
    private func startOnFreeEnergyTimer(createdAt: String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 주어진 문자열의 형식 지정
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC로 지정
        
        /** 에너지 생성 시간대 */
        createdAtDate = dateFormatter.date(from: createdAt)!
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(self.setOnFreeValue(_:)),
                                              userInfo: nil,
                                              repeats: true)
        }
    }
    
    @objc func setOnFreeValue(_ sender: Any) {
        /** 현재 시간대 */
        let now = Date()
        let utcMillis = now.timeIntervalSince1970 * 1000.0
        let nowUtcDate = Date(timeIntervalSince1970: utcMillis / 1000.0)
        
        /** 시간 차 */
        var diff = nowUtcDate.timeIntervalSince(createdAtDate!) * 1000
        
        if(diff >= 172800000) {
            self.timer?.invalidate()
            self.timer = nil
        }
        else{
            DispatchQueue.main.async {
                
                diff = 172800000 - diff
                
                let seconds = Int(diff / 1000)
                let minutes = Int(seconds / 60)
                let hours = Int(minutes / 60)
                let timeString = String(format: "%02d:%02d", hours, minutes % 60)
                
                self.energyLabel.text = "MAX " + timeString
            }
        }
        self.layoutIfNeeded()
    }
    
    private func startEnergyTimer(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 주어진 문자열의 형식 지정
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC로 지정
        
        /** 에너지 갱신 시간대 */
        createdAtDate = dateFormatter.date(from: self.staminaInfo!.staminaLatestUpdate)!
        
        self.timer?.invalidate()
        self.timer = nil
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(self.setEnergyValue(_:)),
                                              userInfo: nil,
                                              repeats: true)
        }
    }
    
    @objc func setEnergyValue(_ sender: Any) {
        /** 현재 시간대 */
        let now = Date()
//        let utcMillis = now.timeIntervalSince1970 * 1000.0 - Double(TimeZone.current.secondsFromGMT() * 1000)
        let utcMillis = now.timeIntervalSince1970 * 1000.0
        let nowUtcDate = Date(timeIntervalSince1970: utcMillis / 1000.0)
        
        /** 시간 차 */
        let diff = nowUtcDate.timeIntervalSince(createdAtDate!) * 1000
        let addedStamina = diff / 600000
        var totalStamina: Int = 0
        
        if staminaInfo!.stamina >= 5 {
            totalStamina = Int(staminaInfo!.stamina)
        } else {
            totalStamina = min(5, Int(staminaInfo!.stamina + addedStamina))
        }
        
        if(totalStamina >= 5) {
            self.timer?.invalidate()
            self.timer = nil
            
            DispatchQueue.main.async {
                self.energyLabel.text = "\(totalStamina) / 5"
                self.remainingTimeLabel.text = ""
            }
            
            return
        }
        else{
            let remainTime = Int(Float(1 - Float(Float(Int(diff) % 600000) / 600000.0)) * 600000)
            let seconds = remainTime / 1000 % 60
            let minutes = remainTime / 1000 / 60
            let timeString = String(format: "%02d : %02d", minutes, seconds)
            
            DispatchQueue.main.async {
                self.energyLabel.text = String(format: "%d / 5", totalStamina)
                self.remainingTimeLabel.text = timeString
            }
        }
        self.layoutIfNeeded()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            self.timer?.invalidate()
            self.timer = nil
        } else {
            if(self.staminaInfo != nil){
                setEnergyBar(staminaInfo: self.staminaInfo!)
            }
        }
    }
}
