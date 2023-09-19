//
//  MTTabBarController.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

class MTTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemBrown
        viewControllers = [createArtistsListNC(), createNewMusicNC()]
    }
    
    func createNewMusicNC() -> UINavigationController {
        let vc = NewMusicVC()
        vc.title = "Music Trail"
        vc.tabBarItem = UITabBarItem(title: "Releases", image: SFSymbol.releasesTab, tag: 1)
        
        return UINavigationController(rootViewController: vc)
    }
    
    func createArtistsListNC() -> UINavigationController {
        let vc = SavedArtistsVC()
        vc.title = "Artists"
        vc.tabBarItem = UITabBarItem(title: "Artists", image: SFSymbol.artistsTab, tag: 0)
        
        return UINavigationController(rootViewController: vc)
    }
}
