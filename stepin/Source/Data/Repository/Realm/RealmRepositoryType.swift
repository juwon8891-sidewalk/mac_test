import Foundation
import RealmSwift

protocol RealmRepositoryType {
    func get() -> Results<VideoInfoTable>?
    func deleteItem(item: Results<VideoInfoTable>) -> Void
}
