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
        vc.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "music.note.list"), tag: 1)
        
        return UINavigationController(rootViewController: vc)
    }
    
    func createArtistsListNC() -> UINavigationController {
        let vc = ArtistsListVC()
        vc.title = "Artists"
        vc.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person.3"), tag: 0)
        
        return UINavigationController(rootViewController: vc)
    }
}
