import CoreData

@objc(CDEpisodeProgress)
public class CDEpisodeProgress: NSManagedObject {
    @NSManaged public var movieId: Int64
    @NSManaged public var episodeId: String?
    @NSManaged public var position: Double
    @NSManaged public var watched: Bool
    @NSManaged public var updatedAt: Date?
}
