import Foundation
import CoreData

public class Post: NSManagedObject {

    @NSManaged public var created_at: String
    @NSManaged public var id: Int64
    @NSManaged public var owner: Int64
    @NSManaged public var post_description: String
    @NSManaged public var title: String
    @NSManaged public var updated_at: String
    @NSManaged public var contained_in: CollectionPosts

}
