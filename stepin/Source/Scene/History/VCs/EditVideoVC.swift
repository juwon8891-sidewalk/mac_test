import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxRelay

class EditVideoVC: UIViewController {
    var viewModel: EditVideoViewModel?
    var disposeBag = DisposeBag()
    var tempBackgroundImage = UIImage()
    var originNeonFrame = CGRect()
    var originViewFrame = CGRect()
    
    var didNeonCreate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.bindViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoView.stopVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.videoView.playerLayer.frame = self.videoView.bounds
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      videoView: self.videoView,
                                                      didViewButtonTapped: self.viewButton.rx.tap.asObservable(),
                                                      didNeonButtonTapped: self.neonButton.rx.tap.asObservable(),
                                                      continueButtonTapp: self.nextButton.rx.tap.asObservable(),
                                                      createButtonTapp: self.navigationView.rightButton.rx.tap.asObservable(),
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      playButton: self.playButton,
                                                      rangeSlider: self.rangeSliderView,
                                                      loadingView: self.neonCreateLoadingView,
                                                      neonColorSelect: self.neonSelectButton),
                                          disposeBag: disposeBag)
        
        output?.didViewButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                self!.didViewButtonTapped(state: self!.viewButton.isSelected)
            })
            .disposed(by: disposeBag)
        
        output?.didNeonCreate
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                self.didNeonCreate = state[1]
                if state[0] && state[1] {
                    DispatchQueue.main.async {
                        self.neonSelectButton.isHidden = true
                        self.nextButton.isHidden = true
                        self.navigationView.rightButton.isHidden = false
                        self.rangeSliderView.isHidden = false
                        self.rangeSliderView.setBackgroundGradient()
                    }
                }
            })
            .disposed(by: disposeBag)

        output?.didNeonButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                self!.didNeonButtonTapped(state: self!.neonButton.isSelected,
                                          didNeonCreate: self!.didNeonCreate)
            })
            .disposed(by: disposeBag)
        
        
        output?.didNextButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                if state {
                    vc.rangeSliderView.setBackgroundGradient()
                    vc.nextButton.setTitle("edit_video_view_next_button_title".localized(), for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        output?.currentTime
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, currentTime) in
                self.currentTimeLabel.text = currentTime
            })
            .disposed(by: disposeBag)
        
        output?.endTime
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vc, endTime) in
                self.endTimeLabel.text = endTime
            })
            .disposed(by: disposeBag)
    }
    
    private func didNeonButtonTapped(state: Bool, didNeonCreate: Bool) {
        if !state { //네온 선택시
            self.originNeonFrame = self.neonButton.frame
            self.originViewFrame = self.viewButton.frame
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.neonButton.center = self.viewButton.center
                self.viewButton.frame.origin = .init(x: self.viewButton.frame.minX - (ScreenUtils.setWidth(value: 20) + self.neonButton.frame.width), y: self.viewButton.frame.minY)
            } completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.neonButton.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                    self.neonButton.bounds.size = CGSize.init(width: self.neonButton.bounds.size.width, height: self.neonButton.bounds.size.height)
                    self.viewButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    self.viewButton.bounds.size = CGSize.init(width: self.viewButton.bounds.size.width, height: self.viewButton.bounds.size.height)
                }
                self.neonButton.isSelected = !self.neonButton.isSelected
                self.viewButton.isSelected = !self.viewButton.isSelected
                
                if self.didNeonCreate {
                    self.navigationView.rightButton.isHidden = false
                    self.rangeSliderView.isHidden = false
                    self.rangeSliderView.setBackgroundGradient()
                    self.currentTimeLabel.isHidden = false
                    self.endTimeLabel.isHidden = false
                    self.neonSelectButton.isHidden = true
                    self.nextButton.isHidden = true
                } else {
                    self.navigationView.rightButton.isHidden = true
                    self.rangeSliderView.isHidden = true
                    self.currentTimeLabel.isHidden = true
                    self.endTimeLabel.isHidden = true
                    self.neonSelectButton.isHidden = false
                    self.nextButton.isHidden = false
                }
            }
            self.viewButton.alpha = 0.7
            self.neonButton.alpha = 1.0
        }
    }
    
    
    private func didViewButtonTapped(state: Bool) {
        if !state {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.viewButton.transform = .identity
                self.neonButton.transform = .identity
            } completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.neonButton.frame.origin = self.originNeonFrame.origin
                    self.viewButton.frame.origin = self.originViewFrame.origin
                }
                self.viewButton.isSelected = !self.viewButton.isSelected
                self.neonButton.isSelected = !self.neonButton.isSelected
                self.navigationView.rightButton.isHidden = false
                self.rangeSliderView.isHidden = false
                self.rangeSliderView.setDefaultBackgroundView()
                self.currentTimeLabel.isHidden = false
                self.endTimeLabel.isHidden = false
                self.neonSelectButton.isHidden = true
                self.nextButton.isHidden = true
            }
            self.viewButton.alpha = 1.0
            self.neonButton.alpha = 0.7
        }
    }
    
    private func setLayout() {
        self.view.backgroundColor = .PrimaryBlackHeavy
        self.view.addSubviews([backgroundImageView, navigationView, videoView, rangeSliderView, nextButton, neonSelectButton, currentTimeLabel, endTimeLabel])
        self.backgroundImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.navigationView.setTitle(title: "edit_video_view_navigation_title".localized())
        
        self.videoView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(90.adjustedH)
        }
        self.videoView.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        self.videoView.layer.borderWidth = 1
        self.videoView.layer.borderColor = UIColor.stepinWhite100.cgColor
        self.videoView.clipsToBounds = true
        self.videoView.addSubviews([viewButton, neonButton, playButton])
        
        self.playButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
        self.viewButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(ScreenUtils.setHeight(value: 20))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.viewButton.layer.cornerRadius = ScreenUtils.setWidth(value: 24)
        self.viewButton.clipsToBounds = true
        self.viewButton.isSelected = true
        
        self.neonButton.snp.makeConstraints {
            $0.centerY.equalTo(self.viewButton)
            $0.leading.equalTo(self.viewButton.snp.trailing).offset(ScreenUtils.setWidth(value: 10))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.neonButton.layer.cornerRadius = ScreenUtils.setWidth(value: 12)
        self.neonButton.clipsToBounds = true
        self.neonButton.isSelected = false
        
        self.rangeSliderView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.videoView.snp.bottom).offset(20.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        
        rangeSliderView.layer.borderColor = UIColor.stepinWhite100.cgColor
        rangeSliderView.layer.borderWidth = 2
        rangeSliderView.layer.cornerRadius = ScreenUtils.setWidth(value: 5)
        rangeSliderView.clipsToBounds = true
        
        self.nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 200))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        nextButton.clipsToBounds = true
        nextButton.isHidden = true
        
        self.view.addSubview(self.neonCreateLoadingView)
        neonCreateLoadingView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        neonCreateLoadingView.isHidden = true
        
        
        neonSelectButton.snp.makeConstraints {
            $0.trailing.equalTo(self.videoView.snp.trailing).inset(20.adjusted)
            $0.bottom.equalTo(self.videoView.snp.bottom).inset(20.adjusted)
            $0.width.equalTo(48)
            $0.height.equalTo(216)
        }
        neonSelectButton.isHidden = true
        
        currentTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(self.rangeSliderView.snp.leading)
            $0.top.equalTo(self.rangeSliderView.snp.bottom).offset(8.adjusted)
        }
        
        endTimeLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.rangeSliderView.snp.trailing)
            $0.top.equalTo(self.rangeSliderView.snp.bottom).offset(8.adjusted)
        }
    }
    
    private var backgroundImageView = UIImageView(image: ImageLiterals.historyBackground)
    private var navigationView = TitleNavigationView().then {
        $0.setRightButtonImage(image: ImageLiterals.icRightArrow)
    }
    private var videoView = BaseVideoView(frame: .init(origin: .zero,
                                                         size: .init(width: 312.adjusted,
                                                                     height: 493.adjustedH)))
    private var playButton = UIButton().then {
        $0.setImage(ImageLiterals.icFloatingPlay, for: .normal)
    }
    private var viewButton = UIButton().then {
        $0.backgroundColor = .PrimaryBlackAlternative
        $0.setImage(SDSIcon.icViewOn, for: .normal)
    }
    private var neonButton = UIButton().then {
        $0.setBackgroundImage(ImageLiterals.icNeonColorSelectedBackground, for: .normal)
        $0.setBackgroundImage(ImageLiterals.icNeonColorSelectedBackground, for: .selected)
        $0.setTitle("".localized(), for: .normal)
        $0.setTitle("edit_video_view_change_neon_button".localized(), for: .selected)
        $0.titleLabel?.font = SDSFont.caption1.font.withSize(8)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.PrimaryWhiteNormal, for: .selected)
    }
    private var rangeSliderView = VideoRangeSlider(frame: .init(origin: .zero,
                                                                size: .init(width: ScreenUtils.setWidth(value: 44),
                                                                            height: ScreenUtils.setWidth(value: 20))))
    private var nextButton = SDSCategoryButton(type: .largeExtraBold).then {
        $0.backgroundColor = .PrimaryBlackNormal
        $0.layer.cornerRadius = 24.adjusted
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.layer.borderWidth = 2
        $0.setTitle("edit_video_view_next_button_title".localized(), for: .normal)
    }
    private var neonCreateLoadingView = NeonLoadingView()
    private var neonSelectButton = HistoryNeonColorSelectButton()
    private let currentTimeLabel = UILabel().then {
        $0.font = SDSFont.body.font.withSize(12)
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    private let endTimeLabel = UILabel().then {
        $0.font = SDSFont.body.font.withSize(12)
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
}
