import CoreData

@objc(CDFavorite)
public class CDFavorite: NSManagedObject {
    @NSManaged public var addedAt: Date?
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var year: String?
    @NSManaged public var desc: String?
    @NSManaged public var genre: String?
    @NSManaged public var rating: String?
    @NSManaged public var duration: String?
    @NSManaged public var isSeries: Bool
    @NSManaged public var translate: String?
    @NSManaged public var isAdIn: Bool
    @NSManaged public var movieURL: String?
    @NSManaged public var posterURL: String?
    @NSManaged public var lastAdded: String?
    @NSManaged public var actorsJSON: String?
    @NSManaged public var directorsJSON: String?
    @NSManaged public var genreListJSON: String?
}
