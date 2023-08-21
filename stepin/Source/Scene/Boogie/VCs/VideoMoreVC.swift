import UIKit
import RxSwift
import Then
import SnapKit
import RxRelay

class VideoMoreVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: VideoMoreViewModel?
    
    internal var viewTag: BottomSheetType = .notLogin

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.animateBlurView()
        
        switch viewTag {
        case .notLogin:
            self.setMyVideoLayout()
        case .myVideo:
            self.setMyVideoLayout()
        case .otherVideo:
            self.setOtherVideoLayout()
        default:
            break
        }
        self.bindViewModel()
        //레이아웃
        //헤이트 안올라오는 오류 수정
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(videoBottomSheet: self.videoBottomSheet,
                                                      otherVideoBottomSheet: self.otherVideoBottomSheet),
                                          disposeBag: disposeBag)
    }
    
    private func animateBlurView() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.blurView.alpha = 1
        }
    }
    
    private func setMyVideoLayout() {
        self.view.addSubviews([blurView, videoBottomSheet])
        self.blurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        self.blurView.alpha = 0
        self.videoBottomSheet.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview()
//            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
//            $0.height.equalTo(ScreenUtils.setWidth(value: 132))
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func setOtherVideoLayout() {
        self.view.addSubviews([blurView, otherVideoBottomSheet])
        self.blurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        self.blurView.alpha = 0
        self.otherVideoBottomSheet.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview()
//            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
//            $0.height.equalTo(ScreenUtils.setWidth(value: 261))
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var videoBottomSheet = MyVideoBottomSheet(size: .init(width: UIScreen.main.bounds.width,
                                                                   height: ScreenUtils.setWidth(value: 160)))
    
    private var otherVideoBottomSheet = VideoBottomSheet(size: .init(width: UIScreen.main.bounds.width,
                                                                     height: ScreenUtils.setWidth(value: 261)))

}
