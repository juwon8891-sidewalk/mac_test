import UIKit
import SDSKit
import Then
import SnapKit
import Lottie
import RxSwift
import RxRelay

class DanceInfoView: UIView {
    var viewModel: DanceInfoViewModel?
    var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    internal func bindViewModel() {
        let output = viewModel?.transform(from: .init(progressBar: self.progressBar), disposeBag: disposeBag)
        
        output?.singerName
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] singerName in
                self?.musicianNameLabel.text = singerName
            })
            .disposed(by: disposeBag)
        
        output?.musicName
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] musicName in
                self?.musicNameLabel.text = musicName
            })
            .disposed(by: disposeBag)
        
        output?.musicCoverImagePath
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] path in
                guard let url = URL(string: path) else {return}
                self?.musicProfileImageView.kf.setImage(with: url)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setLayout() {
        self.addSubviews([musicProfileImageView, musicNameLabel, musicianNameLabel, heartButton, progressBar, bottomGradientView])
        musicProfileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        musicProfileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        musicProfileImageView.clipsToBounds = true
        
        musicNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.musicProfileImageView.snp.top).offset(3)
            $0.leading.equalTo(musicProfileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        musicianNameLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.musicProfileImageView.snp.bottom).inset(3)
            $0.leading.equalTo(musicNameLabel.snp.leading)
            $0.height.equalTo(ScreenUtils.setWidth(value: 17))
        }
        heartButton.snp.makeConstraints {
            $0.centerY.equalTo(self.musicProfileImageView)
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 44))
            $0.height.equalTo(ScreenUtils.setWidth(value: 36))
        }
        progressBar.snp.makeConstraints {
            $0.top.equalTo(musicianNameLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 24))
            $0.bottom.equalTo(bottomGradientView.snp.top).offset(ScreenUtils.setWidth(value: -20))
        }
        bottomGradientView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(1)
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(1)
        }
    }
    
    private var musicProfileImageView = UIImageView(image: SDSIcon.icDefaultProfile)
    private var musicNameLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
        $0.text = ""
    }
    private var musicianNameLabel = UILabel().then {
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
        $0.text = ""
    }
    internal var heartButton = UIButton().then {
        $0.setImage(SDSIcon.icHeartUnfill, for: .normal)
        $0.setImage(SDSIcon.icHeartFill, for: .selected)
    }
    internal var progressBar = MusicProgressBar(size: .init(width: UIScreen.main.bounds.width,
                                                           height: ScreenUtils.setWidth(value: 24)))
    private var bottomGradientView = HorizontalGradientView(width: ScreenUtils.setWidth(value: 343))
}
