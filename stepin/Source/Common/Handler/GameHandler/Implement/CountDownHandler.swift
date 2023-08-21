import Foundation

final class CountDownHandler: NSObject {
    private var count: Int = 6
    weak var delegate: CountDownProtocol?
    override init() {
        super.init()
    }
    
    deinit {
        self.delegate = nil
        print("deinit count")
    }
    
    //MARK: - Timer
    var timer: Timer? = nil
    var isPause: Bool = true
    
    func startTimer() {
        guard timer == nil else { return }
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(self.setCurrentValue),
                                              userInfo: nil,
                                              repeats: true)
        }
        timer?.fire()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        self.count = 6
    }
    
    @objc private func setCurrentValue() {
        self.delegate?.countdownStatus(count: count)
        self.count -= 1
        if self.count == -1 {
            self.stopTimer()
        }
        
    }
}
