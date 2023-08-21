import UIKit
import SDSKit
import CropViewController

class ChoseProfileImageVC: CropViewController {
    var imageCompletion: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(croppingStyle: CropViewCroppingStyle, image: UIImage) {
        super.init(croppingStyle: .default, image: image)
        setViewConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        //crop된 이미지 항목
        guard let completion = imageCompletion else {return}
        completion(image ?? SDSIcon.icDefaultProfile)
        self.dismiss(animated: true)
        print(image)
    }
    
    private func setViewConfig() {
        self.doneButtonHidden = true
        self.cancelButtonHidden = true
        self.cropView.addSubview(navigationView)
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.cropView.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        
        navigationView.setTitle(title: "edit_mypage_choose_profile_image_title".localized())
        navigationView.setRightButtonTextColor(color: .stepinWhite100)
        navigationView.setRightButtonText(text: "edit_mypage_choose_profile_done_button_title".localized())
        
        navigationView.backButtonCompletion = {
            self.dismiss(animated: true)
        }
        navigationView.rightButtonCompletion = {
            self.commitCurrentCrop()
        }
    }
    
    private var navigationView = TitleNavigationView()
}
