//
//  UIViewController+Ext.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/18/23.
//

import UIKit

extension UIViewController {
    
    func presentMTAlert(title: String, message: String, buttonTitle: String) {
        let alertVC = MTAlertVC(alertTitle: title, alertMessage: message, buttonTitle: buttonTitle)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        self.present(alertVC, animated: true)
    }
    
    func presentDefaultError() {
        let alertVC = MTAlertVC(alertTitle: "Unknown error occurred",
                                alertMessage: "We were unable to complete your request. Please try again.",
                                buttonTitle: "Ok")
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        self.present(alertVC, animated: true)
    }
}
