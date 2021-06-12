//
//  Person+CoreDataProperties.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//
//

import Foundation
import CoreData

extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var id: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var notes: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date?
    @NSManaged public var location: Location?
    
    var unwrappedId: String {
        id ?? "Unknown id"
    }

    var unwrappedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date ?? Date())
    }
    
    var unwrappedFirst: String {
        firstName ?? "Unknown first name"
    }

    var unwrappedLast: String {
        lastName ?? "Unknown last name"
    }
    
    var unwrappedName: String {
        "\(unwrappedFirst) \(unwrappedLast)"
    }
    
    var unwrappedNotes: String {
        notes ?? "No notes"
    }

}

extension Person : Identifiable {

}
