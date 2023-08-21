import Foundation
import SDSKit
import RxCocoa
import RxSwift
import PhotosUI

final class EditMyPageViewModel {
    weak var coordinator: EditMyProfileCoordinator?
    private var userRepository: UserRepository?
    private var authRepository: AuthRepository?
    private var tokenUtil = TokenUtils()
    
    let changePhotRelay = PublishRelay<[UIImage]>()
    let idTextFileRelay = PublishRelay<TextFieldState>()
    let nickNameTextFileRelay = PublishRelay<TextFieldState>()
    var doneButtonState: Bool = false
    var image = UIImage()
    var isImageEnable: Bool = false
    var input: Input?
    
    var isVideoChanged: Bool = false
    var videoId: String = ""
    var videoPath: String = ""
    
    private var changedId: String = ""
    private var changedNickname: String = ""
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let viewDidDisappear: Observable<Void>
        let idTextField: EditMyPageTextField
        let nickNameTextField: EditMyPageTextField
        let profileImageTapped: Observable<UITapGestureRecognizer>
        let doneButtonTapped: Observable<Void>
        let selectProfilePicture: Observable<UITapGestureRecognizer>
        let selectBackgroundVideo: Observable<UITapGestureRecognizer>
        let loadingView: UIView
        let changePhotoArray: [UIImage]
        let bottomAlertView: SelectImageAlertView
        let videoView: MyPageVideoView
        let didBackGroundGradientViewTapped: Observable<UITapGestureRecognizer>
    }
    
    struct Output {
        var doneButtonState = PublishRelay<Bool>()
        var profileImageState = PublishRelay<Bool>()
        var backGroundVideo = PublishRelay<String>()
    }
    
    init(coordinator: EditMyProfileCoordinator,
         userRepository: UserRepository,
         authRepository: AuthRepository) {
        self.coordinator = coordinator
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        self.changedId = input.idTextField.textField.text ?? ""
        self.changedNickname = input.nickNameTextField.textField.text ?? ""
        
        input.viewDidAppear
            .withUnretained(self)
            .subscribe(onNext: { (_, videoId) in
                if self.videoPath != "" {
                    output.backGroundVideo.accept(self.videoPath)
                }
                if self.isVideoChanged {
                    self.doneButtonState = true
                    output.doneButtonState.accept(self.doneButtonState)
                }
            })
            .disposed(by: disposeBag)
        
        input.viewDidDisappear
            .withUnretained(self)
            .subscribe(onNext: { (_, videoId) in
                input.videoView.disposeVideoView()
            })
            .disposed(by: disposeBag)
        
        input.nickNameTextField.textField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] text in
                self?.changedNickname = text
                if input.nickNameTextField.textFieldState == .complete {
                    output.doneButtonState.accept(true)
                    self!.doneButtonState = true
                } else {
                    output.doneButtonState.accept(false)
                    self!.doneButtonState = false
                }
            })
            .disposed(by: disposeBag)
        
        input.idTextField.textField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] text in
                self!.changedId = text
                if input.idTextField.textFieldState == .complete {
                    output.doneButtonState.accept(true)
                    self!.doneButtonState = true
                } else {
                    output.doneButtonState.accept(false)
                    self!.doneButtonState = false
                }
            })
            .disposed(by: disposeBag)
        
        input.profileImageTapped
            .when(.recognized)
            .asDriver{ _ in .never()}
            .drive(onNext: { [weak self] gesture in
                output.profileImageState.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.doneButtonTapped
            .subscribe(onNext: { [weak self] in
                if self!.doneButtonState {
                    self?.patchModityUser(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.didBackGroundGradientViewTapped
            .when(.recognized)
            .asDriver{ _ in .never()}
            .drive(onNext: { [weak self] gesture in
                if input.videoView.isPlayEnd {
                    input.videoView.setTimeToVideo(time: 0) { _ in 
                        input.videoView.playVideo()
                    }
                } else {
                    if input.videoView.isPlaying {
                        input.videoView.pauseVideo()
                    } else {
                        input.videoView.playVideo()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        changePhotRelay
            .subscribe(onNext: { [weak self] images in
                if images.count > 0 {
                    self?.image = images.first!
                    self!.isImageEnable = true
                    output.doneButtonState.accept(true)
                    self?.doneButtonState = true
                } else {
                    output.doneButtonState.accept(false)
                    self?.doneButtonState = false
                }
            })
            .disposed(by: disposeBag)
        
        input.bottomAlertView.backgroundCompletion = { [weak self] in
            guard let self = self else {return}
            self.coordinator?.pushToSelectVideoView()
        }
        
        return output
    }
    
    private func patchModityUser(input: Input, disposeBag: DisposeBag) {
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { (_, _) in (self.userRepository?.patchUserInfo(stepinId: self.changedId,
                                                                     name: self.changedNickname,
                                                                     videoId: self.isVideoChanged ? self.videoId: nil))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                if result.statusCode == 200 {
                    UserDefaults.standard.set(self.changedId, forKey: UserDefaultKey.identifierName)
                    UserDefaults.standard.set(self.changedNickname, forKey: UserDefaultKey.name)
                    if self.isImageEnable {
                        self.putImage(data: result.data, disposeBag: disposeBag)
                    } else {
                        self.coordinator?.popToPreiview()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func putImage(data: PatchModifyProfileData, disposeBag: DisposeBag) {
        DispatchQueue.main.async {
            self.input?.loadingView.isHidden = false
        }
        self.userRepository?.putImage(url: data.signedURL.first!.signedURL,
                                      headerValue: data.signedURL.first!.extensionHeadersValueArray,
                                      image: self.image)
        .observe(on: MainScheduler.asyncInstance)
        .withUnretained(self)
        .subscribe(onNext: { _ in
            DispatchQueue.main.async {
                self.input?.loadingView.isHidden = true
            }
            self.coordinator?.popToPreiview()
        })
        .disposed(by: disposeBag)
    }
}

extension EditMyPageVC: PHPickerViewControllerDelegate {
    internal func imageCrop() {
        let cropViewController = ChoseProfileImageVC(croppingStyle: .circular, image: selectedImage)
        self.present(cropViewController, animated: true, completion: nil)
        
        cropViewController.imageCompletion = { image in
            self.changeImage.insert(image, at: 0)
            self.profileImageView.image = self.changeImage[0]
            self.viewModel?.changePhotRelay.accept(self.changeImage)
            
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 1
        let itemProvider = results.first?.itemProvider // 2
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4
                self.selectedImage = (image as? UIImage) ?? SDSIcon.icDefaultProfile
                DispatchQueue.main.async {
                    self.imageCrop()
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
    
    internal func configPHPikcer() {
        configuration.filter = .images
        configuration.selectionLimit = 1
    }
    
    internal func presentImagePickerView() {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
}
