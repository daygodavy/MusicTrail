//
//  MusicArtist+CoreDataProperties.swift
//  MusicTrail
//
//  Created by Davy Chuon on 8/18/23.
//
//

import Foundation
import CoreData


extension MusicArtist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MusicArtist> {
        return NSFetchRequest<MusicArtist>(entityName: "MusicArtist")
    }

    @NSManaged public var artistUrl: URL?
    @NSManaged public var genreName: String?
    @NSManaged public var imageUrl: URL?
    @NSManaged public var isLibrary: Bool
    @NSManaged public var isTracked: Bool
    @NSManaged public var name: String?
    @NSManaged public var artistId: String?

}

extension MusicArtist : Identifiable {

}
