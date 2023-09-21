//
//  MusicRecord+CoreDataProperties.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/21/23.
//
//

import Foundation
import CoreData


extension MusicRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MusicRecord> {
        return NSFetchRequest<MusicRecord>(entityName: "MusicRecord")
    }

    @NSManaged public var artistID: String?
    @NSManaged public var artistName: String?
    @NSManaged public var genres: String?
    @NSManaged public var imageUrl: URL?
    @NSManaged public var isExplicit: Bool
    @NSManaged public var isSingle: Bool
    @NSManaged public var recordID: String?
    @NSManaged public var recordUrl: URL?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var artist: MusicArtist?

}

extension MusicRecord : Identifiable {

}
