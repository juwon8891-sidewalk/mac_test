import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay

class SelectMypageVideoVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: SelectMypageVideoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.setNavigationConfig()
        self.configCollectionViewConfig()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let output = self.viewModel?.transform(from: .init(collectionView: self.collectionView,
                                                           didBackButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                           didDoneButtonTapped: self.navigationView.rightButton.rx.tap.asObservable()),
                                               disposeBag: disposeBag)
    }
    
    private func setNavigationConfig() {
        if let stepinId = UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) {
            self.navigationView.setTitle(title: stepinId)
        }
        self.navigationView.setRightButtonImage(image: ImageLiterals.icRightArrow)
    }
    
    private func configCollectionViewConfig() {
        self.collectionView.register(SelectedMyVideoCVC.self, forCellWithReuseIdentifier: SelectedMyVideoCVC.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: (UIScreen.main.bounds.width / 3) - 6,
                                height: UIScreen.main.bounds.height * 0.22)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        layout.scrollDirection = .vertical
        collectionView.contentInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([collectionView, navigationView])
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private let navigationView = TitleNavigationView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.alwaysBounceVertical = true
        $0.backgroundColor = .stepinBlack100
    }
    
}
