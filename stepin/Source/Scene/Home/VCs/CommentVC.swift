import UIKit
import SnapKit
import Then
import RxSwift
import SkeletonView

class CommentVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: CommentViewModel?
    
    private var viewTranslation = CGPoint(x: 0, y: 0)
    private var viewMaxTranslation = CGPoint(x: 0, y: 0)
    private var viewVelocity = CGPoint(x: 0, y: 0)
    private var spaceHeight = (UIScreen.main.bounds.height - (ScreenUtils.setHeight(value: 503)))
    var keyboardHeight: CGFloat = 0
    var fullScreenFlag: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.setTableViewConfig()
        self.addPanGesture()
        self.initNotificationCenter()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func fullScreenUpdate() { // full screen으로 만들어줌
        self.fullScreenFlag = true
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        guard let top = window?.safeAreaInsets.top else {return}
        backGroundView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(top)
        }
    }
    func notFullScreenUpdate() { // full screen이 아니게 만들어줌.
        self.fullScreenFlag = false
        backGroundView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(self.spaceHeight)
        }
        self.view.endEditing(true)
    }
    
    internal func bindViewModel() {
        
        let output = viewModel?.transform(from: .init(tableView: self.tableView,
                                                      viewDidLoad: self.rx.methodInvoked(#selector(viewDidLoad))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      viewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(), viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:))).map({ _ in }).asObservable(),
                                                      textField: self.editCommentView,
                                                      commentView: self.view,
                                                      didDismissButtonTapped: self.dismissButton.rx.tap.asObservable(),
                                                      reportAlertView: self.reportAlertView),
                                          disposeBag: disposeBag)


    }
    
    @objc private func didTextViewRemakeConstraint(_ notification: Notification) {
        let textViewHeight = self.editCommentView.textView.singleLineTextHeight()
        print(editCommentView.textView.numberOfLine())
        switch self.editCommentView.textView.numberOfLine() {
        case 0...1:
            editCommentView.snp.updateConstraints {
                $0.height.equalTo(ScreenUtils.setWidth(value: 60))
            }
        case 2:
            editCommentView.snp.updateConstraints {
                $0.height.equalTo(ScreenUtils.setWidth(value: 60) + (CGFloat(self.editCommentView.textView.numberOfLine() - 1)) * textViewHeight )
            }
        default:
            editCommentView.snp.updateConstraints {
                $0.height.equalTo(ScreenUtils.setWidth(value: 60) + (2 * textViewHeight) )
            }
        }
    }
    
    private func addPanGesture() {
        self.handleBackgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didModalViewScrolled(_:))))
        
    }
    
    @objc private func didModalViewScrolled(_ sender: UIPanGestureRecognizer) {
        viewTranslation = sender.translation(in: self.backGroundView)
        viewVelocity = sender.translation(in: self.backGroundView)
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        guard let top = window?.safeAreaInsets.top else {return}
        let standardHeight = (self.spaceHeight - top) / 2
        switch sender.state {
        case .changed:
            self.backGroundView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(self.spaceHeight + self.viewTranslation.y)
            }
            if self.fullScreenFlag {
                self.backGroundView.snp.updateConstraints {
                    $0.top.equalToSuperview().offset(self.viewTranslation.y + top)
                }
            }
        case .ended:
            switch viewTranslation.y {
            case 0...: // 아래로 스크롤시
                if self.spaceHeight > backGroundView.frame.origin.y && abs(viewTranslation.y) < standardHeight { // full screen 일떄 스크롤이 절반을 못넘기면 safeArea에 붙음
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backGroundView.snp.updateConstraints {
                            $0.top.equalToSuperview().offset(top)
                        }
                        self.fullScreenFlag = true
                        self.view.layoutIfNeeded()
                    })
                
                } else if self.spaceHeight < backGroundView.frame.origin.y && abs(viewTranslation.y) > standardHeight { // full screen 아닐떄 스크롤이 절반을 넘기면 dismiss
                    dismiss(animated: true, completion: nil)
                } else { // full screen 일떄 스크롤이 절반을 넘기면 본래 backGroundView 위치로 돌아옴.
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backGroundView.snp.updateConstraints {
                            $0.top.equalToSuperview().offset(self.spaceHeight)
                        }
                        self.fullScreenFlag = false
                        self.view.layoutIfNeeded()
                    })
                }
                
            default: // 위로 스크롤시 
                if viewTranslation.y > (-standardHeight) {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backGroundView.snp.updateConstraints {
                            $0.top.equalToSuperview().offset(self.spaceHeight)
                        }
                        self.fullScreenFlag = false
                        self.view.layoutIfNeeded()

                    })
                } else  {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backGroundView.snp.updateConstraints {
                            $0.top.equalToSuperview().offset(top)
                        }
                        
                        self.fullScreenFlag = true
                        self.view.layoutIfNeeded()

                    })
                }
            }
        default:
            break
        }
    }
    
    func initNotificationCenter() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

   
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTextViewRemakeConstraint),
            name: .textView,
            object: nil
        )
    }
    func removeNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .textView,
                                                  object: nil)


    }
    
    @objc internal func keyboardWillShow(_ notification: Notification) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        guard let top = window?.safeAreaInsets.top else {return}
        guard let bottom = window?.safeAreaInsets.bottom else {return}
        let height = (UIScreen.main.bounds.height - (self.backGroundView.bounds.height + self.editCommentView.bounds.height + self.handleBackgroundView.bounds.height) + top)
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 1) {
                
                self.keyboardHeight = keyboardHeight

                print("comment:",  self.view.frame.origin.y ,self.fullScreenFlag, keyboardHeight, self.editCommentView.textView.keyboardType == .default )
                
                if self.fullScreenFlag {
                    self.view.frame.origin.y = 0
                    self.editCommentView.snp.updateConstraints {
                        $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight - bottom)
                    }
                } else {
                    self.view.frame.origin.y = -(self.spaceHeight - top)
                    self.editCommentView.snp.updateConstraints {
                        $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight - bottom - (self.spaceHeight - top - bottom))
                    }
                    
                }
                self.view.setNeedsLayout()
            }
        }
        
    }
    
    @objc internal func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 1) {
            self.view.frame.origin.y = 0
            self.editCommentView.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func setTableViewConfig() {
        self.tableView.register(CommentsTVC.self, forCellReuseIdentifier: CommentsTVC.identifier)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = ScreenUtils.setWidth(value: 200)
        
        let refreshControll = UIRefreshControl()
        refreshControll.backgroundColor = .clear
        refreshControll.tintColor = .stepinBlack40
        self.tableView.refreshControl = refreshControll
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func initEditCommentViewConstraints() {
        editCommentView.snp.updateConstraints {
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
    }
    
    private func setLayout() {
        
        self.view.backgroundColor = .clear
        handleBackgroundView.addSubviews([commentsLabel,handleView, dismissButton])
        commentsLabel.snp.makeConstraints {
            $0.top.equalTo(self.dismissButton.snp.top)
            $0.leading.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(self.dismissButton.snp.bottom)
            $0.trailing.equalTo(self.dismissButton.snp.leading).offset(ScreenUtils.setWidth(value: 216))
        }
        
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 60))
            $0.height.equalTo(ScreenUtils.setWidth(value: 5))
        }
        handleView.layer.cornerRadius = ScreenUtils.setWidth(value: 3)
        dismissButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
        self.view.addSubview(backGroundView)
        backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backGroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        
        self.handleBackgroundView.clipsToBounds = true
        backGroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(self.spaceHeight)
        }
        handleBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        handleBackgroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        self.backGroundView.addSubviews([handleBackgroundView, tableView, gradientView])
        
        self.view.addSubview(editCommentView)
        
        gradientView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(tableView)
        }
        
        handleBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 68))
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(handleBackgroundView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.editCommentView.snp.top)
        }
        
        editCommentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.view.addSubview(reportAlertView)
        reportAlertView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        reportAlertView.isHidden = true
        reportAlertView.backgroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        reportAlertView.backgroundView.clipsToBounds = true
        
    }
    
    
    private var backGroundView = UIView().then {
        $0.backgroundColor = .stepinGray
    }
    private let gradientView = UIView().then {
        $0.backgroundColor = .stepinWhite20
    }
    private var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .stepinBlack100
        $0.separatorStyle = .none
    }
    
    private var handleBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    private var commentsLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.text = "comment_view_comment".localized()
        $0.textColor = .stepinWhite100
    }
    private var handleView = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
    private var dismissButton = UIButton().then {
        $0.setBackgroundImage(ImageLiterals.icWhiteX, for: .normal)
    }
    private var editCommentView = EditCommentTextView(frame: CGRect(origin: .zero, size: .init(width: UIScreen.main.bounds.width,
                                                                                               height: ScreenUtils.setWidth(value: 60)))).then {
        $0.backgroundColor = .stepinGray
    }
    private var reportAlertView = ReportAlertView()
    
    
}
