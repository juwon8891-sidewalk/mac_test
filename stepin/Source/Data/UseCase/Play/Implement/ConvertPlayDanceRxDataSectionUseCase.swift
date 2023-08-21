import Foundation

final class ConvertPlayDanceRxDataSectionUseCase {
    // model -> RxdataSection
    func modelConvert(model: PlayDanceDataModel) -> PlayDanceTableViewDataSection {
        return PlayDanceTableViewDataSection(items: model.data.dance)
    }
}
