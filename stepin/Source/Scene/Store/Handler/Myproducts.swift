import Foundation

enum MyProducts {
//    static let energy_8 = "energy_100"
//    static let energy_18 = "energy_200"
//    static let energy_49 = "energy_500"
//    static let energy_105 = "energy_1000"
    static let energy_8 = "energy_bundle_s"
    static let energy_18 = "energy_bundle_m"
    static let energy_49 = "energy_bundle_l"
    static let energy_105 = "energy_bundle_xl"
    static let iapService: IAPServiceType = IAPService(productIDs: Set<String>([energy_8, energy_18, energy_49, energy_105]))
    
    static func getResourceProductName(_ id: String) -> String? {
        return id.components(separatedBy: ".").last
    }
}
