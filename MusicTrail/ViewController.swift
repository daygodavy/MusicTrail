//
//  ViewController.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/11/23.
//


import MusicKit
import MediaPlayer
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            
            await requestMusicAuthorization()
            print(musicAuthStatus)
            print("2222")
         
            do {
                try await checkAppleMusicStatus()
                
                print("333333")
                
            } catch {
                print("error")
            }
            
            
            do {
                try await searchAppleMusic()
            } catch {
                print("error2")
            }
        }
        
        

    }
    



}
