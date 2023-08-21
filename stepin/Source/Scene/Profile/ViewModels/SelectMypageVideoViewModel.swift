import UIKit
import Foundation
import RxSwift
import RxRelay
import RxDataSources

class SelectMypageVideoViewModel: NSObject {
    weak var selectMyPageVideoCoordinator: SelectMypageVideoCoordinator?
    var videoRepository: VideoRepository?
    var authRepository: AuthRepository?
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SelectedVideoCollectionViewDataSection>?
    private var videoPageNum: Int = 1
    private var videoResult: [SelectedVideoCollectionViewDataSection] = [.init(items: [])]
    private var resultRelay = PublishRelay<[SelectedVideoCollectionViewDataSection]>()

    private var isCellSelectedArray: [Bool] = []
    private var selectedIndex: Int = 0

    struct Input {
        let collectionView: UICollectionView
        let didBackButtonTapped: Observable<Void>
        let didDoneButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    init(coordinator: SelectMypageVideoCoordinator,
         videoRepository: VideoRepository,
         authRepository: AuthRepository) {
        self.selectMyPageVideoCoordinator = coordinator
        self.videoRepository = videoRepository
        self.authRepository = authRepository
    }
    
    private func setIsCellSelectedArray() {
        self.videoResult[0].items.forEach { _ in
            self.isCellSelectedArray.append(false)
        }
    }
    
    private func didResetCellSelectedState() {
        for i in 0 ... self.isCellSelectedArray.count - 1 {
            self.isCellSelectedArray[i] = false
        }
    }
    
    private func getSelectedIndex() {
        for i in 0 ... self.isCellSelectedArray.count - 1 {
            if self.isCellSelectedArray[i] {
                self.selectedIndex = i
            }
        }
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        dataSource = RxCollectionViewSectionedReloadDataSource<SelectedVideoCollectionViewDataSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedMyVideoCVC.identifier, for: indexPath) as? SelectedMyVideoCVC else { return UICollectionViewCell() }
            cell.bindCellData(imagePath: dataSource[indexPath.section].items[indexPath.row].thumbnailURL ?? "",
                              isChecked: self.isCellSelectedArray[indexPath.row])
            return cell
        })
        
        input.didBackButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.selectMyPageVideoCoordinator?.popToEditProfile(videoID: self.videoResult[0].items[self.selectedIndex].videoID,
                                                                    videoPath: self.videoResult[0].items[self.selectedIndex].videoURL ?? "")
            })
            .disposed(by: disposeBag)
        
        input.didDoneButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.selectMyPageVideoCoordinator?.popToEditProfile(videoID: self.videoResult[0].items[self.selectedIndex].videoID,
                                                                    videoPath: self.videoResult[0].items[self.selectedIndex].videoURL ?? "")
                
            })
            .disposed(by: disposeBag)
        
        input.collectionView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.getMyVideo(disposeBag: disposeBag)
        
        self.resultRelay
            .bind(to: input.collectionView.rx.items(dataSource: self.dataSource!))
            .disposed(by: disposeBag)
        
        return output
        
    }
    
    private func getMyVideo(disposeBag: DisposeBag) {
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { (_, _) in (self.videoRepository?.getUserVideo(type: "id",
                                                                    userId: UserDefaults.standard.string(forKey: UserDefaultKey.userId) ?? "",
                                                                    page: self.videoPageNum))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                print(result)
                if !result.data.video.isEmpty {
                    self.videoPageNum += 1
                }
                if !self.videoResult.isEmpty {
                    self.videoResult[0].items.append(contentsOf: result.data.video)
                } else {
                    self.videoResult[0].items = result.data.video
                }
                self.setIsCellSelectedArray()
                self.resultRelay.accept(self.videoResult)
            })
            .disposed(by: disposeBag)
    }
}

extension SelectMypageVideoViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectedMyVideoCVC {
            self.didResetCellSelectedState()
            self.isCellSelectedArray[indexPath.row] = !self.isCellSelectedArray[indexPath.row]
            cell.didCellSelected(isSelected: self.isCellSelectedArray[indexPath.row])
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
            self.getSelectedIndex()
            print(self.isCellSelectedArray)
        }
    }
}
