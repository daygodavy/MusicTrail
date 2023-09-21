//
//  MusicArtist+CoreDataProperties.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/21/23.
//
//

import Foundation
import CoreData


extension MusicArtist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MusicArtist> {
        return NSFetchRequest<MusicArtist>(entityName: "MusicArtist")
    }

    @NSManaged public var artistUrl: URL?
    @NSManaged public var catalogID: String?
    @NSManaged public var genreName: String?
    @NSManaged public var imageUrl: URL?
    @NSManaged public var isTracked: Bool
    @NSManaged public var libraryID: String?
    @NSManaged public var name: String?
    @NSManaged public var topSongID: String?
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for records
extension MusicArtist {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: MusicRecord)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: MusicRecord)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension MusicArtist : Identifiable {

}
