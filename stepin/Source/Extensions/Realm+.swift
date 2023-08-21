import RealmSwift
import Foundation

public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}

extension PoseData: Persistable {
    public init(managedObject: PoseTable) {
        self.data = managedObject.dataArray
        self.time = managedObject.time
    }
    public func managedObject() -> PoseTable {
        let poseObj = PoseTable()
        poseObj.dataArray = data
        poseObj.time = time
        return poseObj
    }
}


extension Score: Persistable {
    public init(managedObject: ScoreTable) {
        self.score = managedObject.score
        self.time = managedObject.time
    }
    public func managedObject() -> ScoreTable {
        let scoreObj = ScoreTable()
        scoreObj.score = score
        scoreObj.time = time
        return scoreObj
    }
}
