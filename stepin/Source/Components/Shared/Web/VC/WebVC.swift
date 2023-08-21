import UIKit
import SDSKit
import WebKit
import SnapKit
import Then

enum webViewType {
    case term
    case none
}
class WebVC: UIViewController {
    var webView: WKWebView!
    var agreeButtonCompletion: (() -> Void)?

    
    init(type: webViewType, url: String) {
        super.init(nibName: nil, bundle: nil)
        loadView()
        let url = URL(string: url)
        let request = URLRequest(url: url!)
        webView.load(request)
        if type == .term {
            setAgreeButtonLayout()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame: self.view.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view = self.webView
    }
    
    private func setAgreeButtonLayout() {
        self.view.addSubview(agreeButton)
        agreeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(48.adjusted)
        }
    }
    @objc private func didAgreeButtonClicked(_ sender: UIButton) {
        HapticService.shared.playFeedback()
        guard let completion = agreeButtonCompletion else { return }
        completion()
        self.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private lazy var agreeButton = UIButton().then {
        $0.backgroundColor = .SystemBlue
        $0.setTitle("webView_agree_button_title".localized(), for: .normal)
        $0.addTarget(self,
                     action: #selector(didAgreeButtonClicked(_:)),
                     for: .touchUpInside)
        $0.layer.cornerRadius = 24.adjusted
    }

}
extension WebVC: WKUIDelegate {
}
extension WebVC: WKNavigationDelegate {
}
