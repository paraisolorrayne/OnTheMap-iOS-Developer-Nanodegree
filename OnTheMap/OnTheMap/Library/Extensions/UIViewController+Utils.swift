//
//  UIViewController+.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
    func showConfirmationAlert(withMessage: String, actionTitle: String, action: @escaping () -> Void) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: nil, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (alertAction) in
                action()
            }))
            self.present(ac, animated: true)
        }
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func enableUI(views: UIControl..., enable: Bool) {
        performUIUpdatesOnMain {
            for view in views {
                view.isEnabled = enable
            }
        }
    }
    
    /// Open the given URL using Safari web browser.
    ///
    /// - Parameter url: a valid URL.
    func openWithSafari(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showInfo(withMessage: "Invalid link.")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }

    // Keyboard movements
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            // Fallback on earlier versions
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded();
        }
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            // Fallback on earlier versions
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded();
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height/4
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height/4)
            }
        }
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func keyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillChange(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

