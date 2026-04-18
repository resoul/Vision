import CoreData

@objc(CDPlaybackState)
public class CDPlaybackState: NSManagedObject {
    @NSManaged public var movieId: Int64
    @NSManaged public var season: Int32
    @NSManaged public var episode: Int32
    @NSManaged public var studio: String?
    @NSManaged public var quality: String?
    @NSManaged public var updatedAt: Date?
}
