import UIKit
import SDSKit
import RxSwift
import RxCocoa
import RxRelay

enum EditMyPageTextFieldType {
    case stepinId
    case nickName
}

class EditMyPageTextField: GeneralAuthTextView {
    var disposeBag = DisposeBag()
    private var type: EditMyPageTextFieldType?
    private var editMyPageTextFieldViewModel: EditMyPageTextFieldViewModel?
    internal var textFieldState: TextFieldState = .none
    
    
    init(type: EditMyPageTextFieldType) {
        super.init()
        self.setLayout()
        self.type = type
        
        switch type {
        case .stepinId:
            self.editMyPageTextFieldViewModel = EditMyPageTextFieldViewModel(type: .stepinId)
            self.textField.placeholder = "edit_mypage_stepin_id_text_field_title".localized()
            self.titleLabel.text = "edit_mypage_textfield_id_title".localized()
            
            if let originId = UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) {
                self.textField.text = UserDefaults.standard.string(forKey: UserDefaultKey.identifierName)!
            }
            
        case .nickName:
            self.editMyPageTextFieldViewModel = EditMyPageTextFieldViewModel(type: .nickName)
            self.textField.placeholder = "edit_mypage_nickname_text_field_title".localized()
            self.titleLabel.text = "edit_mypage_textfield_nickname_title".localized()
            
            if let originNickName = UserDefaults.standard.string(forKey: UserDefaultKey.name) {
                self.textField.text = originNickName
            }
        }
        bindEditMyPageViewModel()
    }
    
    private func bindEditMyPageViewModel() {
        let output = editMyPageTextFieldViewModel?.transform(from: .init(didTextFieldEditting: self.textField.rx.text.orEmpty.asObservable()),
                                                             disposeBag: disposeBag)
        output?.currentTextFieldState
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: .none)
            .drive(onNext: { [weak self] state in
                switch self?.type {
                case .stepinId:
                    self!.textFieldState = .none
                    if state == .fail_network {}
                    if state == .formatted_id {
                        self!.setIdBottomSelectedText()
                        self!.setBottomSelectedLineColor()
                        self!.textFieldState = .complete
                    }
                    else if state == .unformatted_id {
                        self!.setIdBottomUnSelectedText()
                        self!.setBottomUnSelectedLineColor()
                    }
                    else if state == .unformatted_dupplicated_id {
                        self!.setIdDuplecatedText()
                        self!.setBottomUnSelectedLineColor()
                    }
                    else if state == .formatted_use_nickname {
                        self!.bottomText.text = ""
                        self?.bottomLine.backgroundColor = .stepinWhite100
                    }
                    else if state == .formatted_id {
                        self!.setBottomSelectedLineColor()
                        self!.setIdBottomSelectedText()
                    }
                case .nickName:
                    self!.textFieldState = .none
                    if state == .formatted_use_nickname {
                        self?.bottomLine.backgroundColor = .stepinWhite100
                        self?.bottomText.text = ""
                    }
                    else if state == .formatted_nickname {
                        self?.setNickNameBottomSelectedText()
                        self!.setBottomSelectedLineColor()
                        self!.textFieldState = .complete
                    } else {
                        self?.setNickNameBottomUnSelectedText()
                        self!.setBottomUnSelectedLineColor()
                    }
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setIdDuplecatedText() {
        self.bottomText.attributedText = NSAttributedString("edit_mypage_contain_already_use_noti".localized().setAttributeString(textColor: .stepinRed100, font: .suitRegularFont(ofSize: 12)))
    }
    
    private func setIdBottomSelectedText() {
        self.bottomText.attributedText = NSAttributedString("edit_mypage_stepin_id_noti_avalible_title".localized().setAttributeString(textColor: .SystemBlue, font: .suitRegularFont(ofSize: 12)))
    }
    
    
    private func setIdBottomUnSelectedText() {
        self.bottomText.attributedText = NSAttributedString("edit_mypage_stepin_nickname_noti_unavalible_title".localized().setAttributeString(textColor: .stepinRed100, font: .suitRegularFont(ofSize: 12)))
    }
    
    private func setNickNameBottomSelectedText() {
        self.bottomText.attributedText = NSAttributedString("edit_mypage_stepin_nickname_noti_avalible_title".localized().setAttributeString(textColor: .SystemBlue, font: .suitRegularFont(ofSize: 12)))
    }
    
    private func setNickNameBottomUnSelectedText() {
        self.bottomText.attributedText = NSAttributedString("edit_mypage_stepin_nickname_noti_avalible_title".localized().setAttributeString(textColor: .stepinRed100, font: .suitRegularFont(ofSize: 12)))
    }
    
    private func setBottomSelectedLineColor() {
        self.bottomLine.backgroundColor = .SystemBlue
    }
    
    private func setBottomUnSelectedLineColor() {
        self.bottomLine.backgroundColor = .stepinRed100
    }
    
    private func setLayout() {
        self.initView.addSubview(textField)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(initView.snp.top).inset(ScreenUtils.setWidth(value: -12))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        textField.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    private var titleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 12)
        $0.textColor = .stepinWhite100
    }
    internal var textField = BaseTextField()
    
}
