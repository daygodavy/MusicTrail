//
//  MusicRecord+CoreDataProperties.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/20/23.
//
//

import Foundation
import CoreData


extension MusicRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MusicRecord> {
        return NSFetchRequest<MusicRecord>(entityName: "MusicRecord")
    }

    @NSManaged public var title: String?
    @NSManaged public var artistName: String?
    @NSManaged public var artistID: String?
    @NSManaged public var recordID: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var imageUrl: URL?
    @NSManaged public var recordUrl: URL?
    @NSManaged public var isExplicit: Bool
    @NSManaged public var genres: String?
    @NSManaged public var isSingle: Bool

}

extension MusicRecord : Identifiable {

}
