//
//  LoaderView.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import Foundation
import UIKit

class LoaderView: UIView {
    
    var isLoading:Bool = false
    
    private var circle: UIView?
    private var loaderIsAlreadySet:Bool = false
    
    func setLoader() {
        loaderIsAlreadySet = true
        isLoading = false
        let screenBounds = UIScreen.main.bounds
        let centerx = screenBounds.width / 2
        let centery = screenBounds.height / 2
        let center:CGPoint =  CGPoint(x:centerx , y: centery)
        frame = screenBounds

        backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.4)//UIColor.black
        
        let image = UIImageView(image: UIImage(named: "worldwide"))
        image.frame = CGRect(x: 0.0, y: 0.0, width: 128.0, height: 128.0)
        image.center = center
        addSubview(image)
        circle = UIView(
            frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0)
        )
        
        circle?.center = center
        circle?.backgroundColor = UIColor.clear
        circle?.layer.borderColor = UIColor(displayP3Red: 232/255.0, green: 65/255.0, blue: 24/255.0, alpha: 1).cgColor//UIColor.red.cgColor
        circle?.layer.cornerRadius = 12.0
        circle?.layer.borderWidth = 2.0
        addSubview(circle!)
    }
    
    func startAnimation(_ viewController:UIViewController) {
        if !loaderIsAlreadySet {
            setLoader()
        }
        isLoading = true
        viewController.view.addSubview(self)
        alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseInOut,.autoreverse,.repeat], animations: {
            let scale = CGAffineTransform(scaleX: 6, y: 6)
            if let circle = self.circle {
                circle.transform = scale.concatenating(circle.transform.rotated(by: CGFloat(Double.pi)))
            }
        })
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.alpha = 0
            self.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
            self.layer.removeAllAnimations()
            self.circle?.layer.removeAllAnimations()
            self.circle?.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.layoutIfNeeded()
            self.isLoading = false
        }
    }
}

