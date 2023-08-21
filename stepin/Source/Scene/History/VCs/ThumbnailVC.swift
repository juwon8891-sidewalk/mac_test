import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ThumbnailVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: ThumbnailViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.bindViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoView.pauseVideo()
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
                                                      applyButtonTapped: self.navigationView.rightButton.rx.tap.asObservable(),
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      playButton: self.playButton,
                                                      rangeSlider: self.rangeSliderView),
                                          disposeBag: disposeBag)
    }
    
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([backgroundImageView, navigationView, videoView, rangeSliderView, currentTimeLabel, endTimeLabel])
        self.backgroundImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.navigationView.setTitle(title: "thumbnail_view_navigation_title".localized())
        self.navigationView.setRightButtonText(text: "thumbnail_view_done_button_title".localized())
        
        self.videoView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(90.adjustedH)
        }
        self.videoView.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        self.videoView.layer.borderWidth = 1
        self.videoView.layer.borderColor = UIColor.stepinWhite100.cgColor
        self.videoView.clipsToBounds = true
        self.videoView.addSubview(playButton)
        
        self.playButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
        self.rangeSliderView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.videoView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 32))
        }
        
        rangeSliderView.layer.borderColor = UIColor.stepinWhite100.cgColor
        rangeSliderView.layer.borderWidth = 2
        rangeSliderView.layer.cornerRadius = ScreenUtils.setWidth(value: 5)
        rangeSliderView.clipsToBounds = true
        
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
    private var navigationView = TitleNavigationView()
    private var videoView = BaseVideoView(frame: .init(origin: .zero,
                                                         size: .init(width: ScreenUtils.setWidth(value: 236),
                                                                     height: ScreenUtils.setHeight(value: 375))))
    private var playButton = UIButton().then {
        $0.setImage(ImageLiterals.icFloatingPlay, for: .normal)
    }
    private var rangeSliderView = VideoRangeSlider(frame: .init(origin: .zero,
                                                                size: .init(width: ScreenUtils.setWidth(value: 44),
                                                                            height: ScreenUtils.setWidth(value: 20))))
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
