//
//  Artist.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/14/23.
//

import Foundation
import MusicKit


struct LibraryArtist: Codable {
    let name: String
    let id: MusicItemID
    let imageUrl: URL?
    var isSaved = false
}

extension LibraryArtist {
    public static func getMockArray() -> [LibraryArtist] {
        return [
            LibraryArtist(name: "NoCap", id: MusicItemID("4990793370372466845"), imageUrl: URL(string: "musicKit://artwork/library/D765CEE9-4946-44FA-926D-6B90E0F81850/168x168?aat=https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/e2/e0/6a/e2e06af2-7c47-2fbb-7930-084fd99f37b2/pr_source.png/1284x1284bb.jpg&at=artistHero&et=albumArtist&fat=&id=4990793370372466845&lid=D765CEE9-4946-44FA-926D-6B90E0F81850&mt=")),
            LibraryArtist(name: "Lil Bean", id: MusicItemID("-3221600713544700702"), imageUrl: URL(string: "musicKit://artwork/library/D765CEE9-4946-44FA-926D-6B90E0F81850/168x168?aat=https://is1-ssl.mzstatic.com/image/thumb/AMCArtistImages116/v4/3b/a3/f3/3ba3f366-7373-8363-57c9-feb7b1d2b7d5/1015b5f7-ff2f-45d6-ae85-0ee24be04170_file_cropped.png/1284x1284bb.jpg&at=artistHero&et=albumArtist&fat=&id=15225143360164850914&lid=D765CEE9-4946-44FA-926D-6B90E0F81850&mt=")),
            LibraryArtist(name: "Mozzy", id: MusicItemID("18928142032388396"), imageUrl: URL(string: "musicKit://artwork/library/D765CEE9-4946-44FA-926D-6B90E0F81850/168x168?aat=https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/a6/08/26/a608263e-7ddc-f42e-25a9-8454bd7c35f2/pr_source.png/1284x1284bb.jpg&at=artistHero&et=albumArtist&fat=&id=18928142032388396&lid=D765CEE9-4946-44FA-926D-6B90E0F81850&mt=")),
            LibraryArtist(name: "Drake", id: MusicItemID("-8481753308158568191"), imageUrl: URL(string: "musicKit://artwork/library/D765CEE9-4946-44FA-926D-6B90E0F81850/168x168?aat=https://is1-ssl.mzstatic.com/image/thumb/AMCArtistImages112/v4/1b/71/65/1b716513-b0c1-9c6b-45aa-cbb9198248cc/01607cf1-1d52-43d2-84ce-d6fc1f4a3475_ami-identity-7665599cc626d803af7956b3691905e7-2022-11-30T21-07-19.526Z_cropped.png/1284x1284bb.jpg&at=artistHero&et=albumArtist&fat=&id=9964990765550983425&lid=D765CEE9-4946-44FA-926D-6B90E0F81850&mt=")),
            LibraryArtist(name: "YoungBoy Never Broke Again", id: MusicItemID("2038627676938128213"), imageUrl: URL(string: "musicKit://artwork/library/D765CEE9-4946-44FA-926D-6B90E0F81850/168x168?aat=https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/0a/66/35/0a6635dc-095d-f19e-48a5-2af956c7b752/pr_source.png/1284x1284bb.jpg&at=artistHero&et=albumArtist&fat=&id=2038627676938128213&lid=D765CEE9-4946-44FA-926D-6B90E0F81850&mt="))
            
        ]
    }
}
//
//extension LibraryArtist {
//    public static func getMockArray() -> [LibraryArtist] {
//        return [
//            LibraryArtist(name: "NoCap", id: MusicItemID("4990793370372466845"), imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/e2/e0/6a/e2e06af2-7c47-2fbb-7930-084fd99f37b2/pr_source.png/168x168bb.jpg")),
//            LibraryArtist(name: "Lil Bean", id: MusicItemID("-3221600713544700702"), imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/AMCArtistImages116/v4/3b/a3/f3/3ba3f366-7373-8363-57c9-feb7b1d2b7d5/1015b5f7-ff2f-45d6-ae85-0ee24be04170_file_cropped.png/168x168bb.jpg")),
//            LibraryArtist(name: "Mozzy", id: MusicItemID("18928142032388396"), imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/a6/08/26/a608263e-7ddc-f42e-25a9-8454bd7c35f2/pr_source.png/168x168bb.jpg")),
//            LibraryArtist(name: "Drake", id: MusicItemID("-8481753308158568191"), imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/AMCArtistImages112/v4/1b/71/65/1b716513-b0c1-9c6b-45aa-cbb9198248cc/01607cf1-1d52-43d2-84ce-d6fc1f4a3475_ami-identity-7665599cc626d803af7956b3691905e7-2022-11-30T21-07-19.526Z_cropped.png/168x168bb.jpg")),
//            LibraryArtist(name: "YoungBoy Never Broke Again", id: MusicItemID("2038627676938128213"), imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/0a/66/35/0a6635dc-095d-f19e-48a5-2af956c7b752/pr_source.png/168x168bb.jpg"))
//
//        ]
//    }
//}



