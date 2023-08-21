import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import SnapKit

class EditCommentTextView: UIView {
    var remakeTextViewCompletion: ((CGFloat) -> Void)?
    var refreshCompletion: (() -> Void)?
    var textViewMaxValue: CGFloat = 0
    var preTextViewHeight: CGFloat = 0
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setTextViewConfig()
        setProfileImage()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: CGRect(origin: .zero, size: .zero))
        setLayout()
        setTextViewConfig()
        setProfileImage()
    }
    private func setTextViewConfig() {
        textView.delegate = self
        textView.isScrollEnabled = false
    }
    
    //MARK: layout
    private func setProfileImage() {
        if (UserDefaults.standard.string(forKey: UserDefaultKey.profileUrl) ?? "") != "" {
            guard let url = URL(string: UserDefaults.standard.string(forKey: UserDefaultKey.profileUrl)!) else {return}
            self.profileImageView.kf.setImage(with: url)
        } else {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        }
    }
    private func setLayout() {
//        self.backgroundColor = .stepinGray
        self.backgroundColor = .stepinWhite20
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2.0
        
        self.addSubviews([textViewPlaceHolder, profileImageView, textView, writeCommentButton])
        
        profileImageView.snp.makeConstraints {
            $0.bottom.equalTo(textView.snp.bottom)
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }

        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 12))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
            $0.leading.equalTo(profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        textViewPlaceHolder.snp.makeConstraints {
            $0.leading.equalTo(textView.snp.leading).offset(16)
            $0.top.equalTo(textView.snp.top).offset(8)
            $0.bottom.equalTo(textView.snp.bottom).inset(8)
            $0.trailing.equalTo(writeCommentButton.snp.leading).inset(ScreenUtils.setWidth(value: 16))
        }
        
        writeCommentButton.snp.makeConstraints {
            $0.bottom.equalTo(textView.snp.bottom).inset(ScreenUtils.setWidth(value: 8))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 28))
            $0.width.equalTo(ScreenUtils.setWidth(value: 31))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }

    }
    
    private let profileImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 40,
                                                                                         height: 40)))
    internal var textView = UITextView().then {
        $0.font = .suitMediumFont(ofSize: 12)
        $0.textColor = .white
        $0.backgroundColor = .clear
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 2
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        //top, bottom 8은 defaultValue
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 59)
        $0.textAlignment = .left
        $0.tintColor = UIColor.white
        $0.showsHorizontalScrollIndicator = false
    }
    
    
    internal let writeCommentButton = UIButton().then {
        $0.backgroundColor = UIColor.clear
        $0.setTitleColor(.stepinWhite40, for: .normal)
        $0.setTitle("comment_view_done_button_title".localized(), for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 12)
    }
    private let textViewPlaceHolder = UILabel().then {
        $0.text = "comment_view_placeholder_title".localized()
        $0.textColor = .stepinWhite40
        $0.font = UIFont.callout()
    }
    
}
extension EditCommentTextView: UITextViewDelegate {
    func setTextviewPlaceHolder() {
        //한글자라도 작성했을 때
        if textView.text != "" {
            textViewPlaceHolder.isHidden = true
            writeCommentButton.setTitleColor(.stepinWhite100, for: .normal)
        } else {
            textViewPlaceHolder.isHidden = false
            writeCommentButton.setTitleColor(.stepinWhite40, for: .normal)
        }
    }
    
    func setTextViewDinamicHeight() {
        //        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        //        let estimatedSize = textView.frame.size
        //        print(textView.frame.height)
        //        //textView 사이즈 조절
        //        textView.constraints.forEach { (constraint) in
        //            if constraint.firstAttribute == .height {
        //                //4줄까지만 늘어나게
        //                if textView.numberOfLine() < 5 {
        //                    textView.isScrollEnabled = false
        //                    constraint.constant = estimatedSize.height
        //                    if estimatedSize.height > self.textViewMaxValue {
        //                        self.textViewMaxValue = estimatedSize.height
        //                    }
        //                    //                          NotificationCenter.default.post(name: Notification.Name("textView"), object: estimatedSize.height)
        //
        //                    //textView와 edit뷰의 높이를 함께 조절하기 위한 클로져
        //                    //                          guard let completion = self.remakeTextViewCompletion else { return }
        //                    //                          completion(estimatedSize.height)
        //                } else {
        //                    textView.isScrollEnabled = true
        //                    textView.snp.remakeConstraints {
        //                        $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
        //                        $0.leading.equalTo(profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
        //                        $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        //                        $0.height.equalTo(ScreenUtils.setWidth(value: self.textViewMaxValue))
        //                    }
        //                }
        //            }
        //        }

        //3줄까지만 늘어나게
        if textView.numberOfLine() < 4 {
            textView.isScrollEnabled = false
        } else {
            textView.isScrollEnabled = true
        }
            
        NotificationCenter.default.post(name: .textView, object: nil )
        
        
    }
    
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        setTextviewPlaceHolder()
        setTextViewDinamicHeight()
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        writeCommentButton.isHidden = false
    }
    
    
    
    
}
