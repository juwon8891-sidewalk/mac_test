import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxRelay
import MarqueeLabel

class HistoryDanceDetailVC: UIViewController {
    var viewModel: HistoryDanceDetailViewModel?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.setLayout()
        self.bindViewModel()
        self.setNavigationConfig()
    }
    
    //MARK: - bind view model
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
            .observe(on: MainScheduler.asyncInstance)
            .map({ _ in })
            .asObservable(),
                                                      videoView: self.videoView,
                                                      playButton: self.playButton,
                                                      uploadButtonTapped: self.uploadButton.rx.tap.asObservable(),
                                                      dismissButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      skeletonButton: self.navigationView.rightButton,
                                                      likeButtonTapped: self.likeButton.rx.tap.asObservable()),
                                          disposeBag: disposeBag)
        
        output?.likeButtonState
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                self.likeButton.isSelected = state
            })
            .disposed(by: disposeBag)
        
        output?.selectedDateString
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: Date())
            .drive(onNext: { [weak self] text in
                self?.navigationView.setTitle(title: text.toString(dateFormat: "yyyy.MM.dd"))
            })
            .disposed(by: disposeBag)
        
        output?.selectedTimeString
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: Date())
            .drive(onNext: { [weak self] text in
                self?.timeLabel.text = text.toString(dateFormat: "hh:mm")
            })
            .disposed(by: disposeBag)
        
        output?.danceInfoDescription
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] text in
//                self?.musicInfoLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output?.musicInfoData
            .withUnretained(self)
            .bind(onNext: { (vc, data) in
                vc.totalDanceInfoView.bindMusicInfoData(musicImagePath: data.cover_url,
                                                        musicTitle: data.dance_name,
                                                        artist: data.artist_name)
            })
            .disposed(by: disposeBag)
        
        output?.totalScore
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] score in
                self?.totalDanceInfoView.setScoreLabelShadow(state: "\(score)".scoreToState(score: Float(score)),
                                                             score: "\(score)",
                                                             color: "\(score)".scoreToColor(score: Float(score)))
            })
            .disposed(by: disposeBag)
        
        output?.detailScoreArray
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] array in
                self?.perfectScoreInfoView.bindText(scoreState: "history_view_score_text_perfect".localized(),
                                                    scorePercent: " \(Int(array[0])) %")
                self?.greatScoreInfoView.bindText(scoreState: "history_view_score_text_great".localized(),
                                                    scorePercent: " \(Int(array[1])) %")
                self?.goodScoreInfoView.bindText(scoreState: "history_view_score_text_good".localized(),
                                                    scorePercent: " \(Int(array[2])) %")
                self?.badScoreInfoView.bindText(scoreState: "history_view_score_text_bad".localized(),
                                                scorePercent: " \(Int(array[3])) %")
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - set componets layout
    private func setNavigationConfig() {
        self.navigationView.rightButton.setImage(ImageLiterals.icSkeleton, for: .normal)
        self.navigationView.rightButton.setImage(ImageLiterals.icSkeletonSelected, for: .selected)
    }
    private func setLayout() {
        self.view.addSubviews([backgroundImageView, scrollView, navigationView])
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(self.view)
        }

        scrollView.addSubviews([timeLabel, videoBackgroundView, totalDanceInfoView, stackView])
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(self.scrollView.snp.top).offset(20)
            $0.leading.equalTo(self.view.snp.leading).offset(ScreenUtils.setWidth(value: 150))
            $0.trailing.equalTo(self.view.snp.trailing).inset(ScreenUtils.setWidth(value: 150))
            $0.height.equalTo(ScreenUtils.setWidth(value: 22))
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top)
            $0.leading.equalTo(self.view.snp.leading)
            $0.trailing.equalTo(self.view.snp.trailing)
            $0.bottom.equalTo(self.view.snp.bottom)
        }
        backgroundImageView.clipsToBounds = false
        videoBackgroundView.addSubview(videoView)
        
        videoBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.timeLabel.snp.bottom).offset(20)
            $0.leading.equalTo(self.view.snp.leading)
            $0.trailing.equalTo(self.view.snp.trailing)
            $0.height.equalTo(ScreenUtils.setHeight(value: 290))
        }
        
        
        
        videoView.addSubview(playButton)
        videoView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(236.adjusted)
            $0.height.equalTo(375.adjustedH)
        }
        
        videoView.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        videoView.layer.borderColor = UIColor.stepinWhite100.cgColor
        videoView.layer.borderWidth = 1
        videoView.clipsToBounds = true
        
        playButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
        totalDanceInfoView.snp.makeConstraints {
            $0.top.equalTo(self.videoView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(self.view).inset(30)
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(totalDanceInfoView.snp.bottom)
            $0.leading.trailing.equalTo(self.view).inset(30)
            $0.height.equalTo(ScreenUtils.setWidth(value: 200))
            $0.bottom.equalTo(self.scrollView.snp.bottom).offset(-100)
        }
        
        stackView.addArrangeSubViews([perfectScoreInfoView, greatScoreInfoView, goodScoreInfoView, badScoreInfoView])
        
        self.view.addSubviews([uploadButton, dismissButton])
        uploadButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 200))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        uploadButton.clipsToBounds = true
        
        self.view.addSubview(likeButton)
        likeButton.snp.makeConstraints {
            $0.trailing.equalTo(self.videoView.snp.trailing).inset(20)
            $0.bottom.equalTo(self.videoView.snp.bottom).inset(20)
            $0.width.height.equalTo(32.adjusted)
        }
        likeButton.clipsToBounds = true
    }
    
    //MARK: -components
    private var scrollView = UIScrollView().then {
        $0.contentInsetAdjustmentBehavior = .never
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }
    private var navigationView = TitleNavigationView()
    
    private var dismissButton = UIButton().then {
        $0.setImage(ImageLiterals.icWhiteX, for: .normal)
    }
    private var backgroundImageView = UIImageView(image: ImageLiterals.historyBackground)
    private var timeLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
    private var videoBackgroundView = UIView().then {
        $0.backgroundColor = .clear
    }
    private var videoView = BaseVideoView(frame: .init(origin: .zero, size: .init(width: 236.adjusted,
                                                                                  height: 375.adjustedH)))
    private var playButton = UIButton().then {
        $0.setImage(ImageLiterals.icFloatingPlay, for: .normal)
    }
    
    private var totalDanceInfoView = ResultHeaderView()
    private var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    private var perfectScoreInfoView = ScoreInfoView()
    private var greatScoreInfoView = ScoreInfoView()
    private var goodScoreInfoView = ScoreInfoView()
    private var badScoreInfoView = ScoreInfoView()
    private var uploadButton = SDSCategoryButton(type: .largeExtraBold).then {
        $0.backgroundColor = .PrimaryBlackNormal
        $0.layer.cornerRadius = 24.adjusted
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.layer.borderWidth = 2
        $0.setTitle("history_detail_upload_button_title".localized(), for: .normal)
    }
    private let likeButton = UIButton().then {
        $0.layer.cornerRadius = 16.adjusted
        $0.layer.borderColor = UIColor.PrimaryWhiteDisabled.cgColor
        $0.layer.borderWidth = 1
        $0.setImage(SDSIcon.icHeartUnfill, for: .normal)
        $0.setBackgroundColor(.PrimaryWhiteAlternative, for: .selected)
        $0.setImage(SDSIcon.icHeartFill, for: .selected)
        $0.setBackgroundColor(.PrimaryWhiteNormal, for: .selected)
    }

}
