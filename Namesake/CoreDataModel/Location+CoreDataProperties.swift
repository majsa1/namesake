//
//  Location+CoreDataProperties.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var name: String?
    @NSManaged public var people: NSSet?

    var unwrappedName: String {
        name ?? "Unknown location"
    }
        
    var personArray: [Person] {
        let set = people as? Set<Person> ?? []
        return set.sorted {
            $0.unwrappedLast < $1.unwrappedLast
        }
    }
}

// MARK: Generated accessors for people
extension Location {

    @objc(addPeopleObject:)
    @NSManaged public func addToPeople(_ value: Person)

    @objc(removePeopleObject:)
    @NSManaged public func removeFromPeople(_ value: Person)

    @objc(addPeople:)
    @NSManaged public func addToPeople(_ values: NSSet)

    @objc(removePeople:)
    @NSManaged public func removeFromPeople(_ values: NSSet)

}

extension Location : Identifiable {

}
