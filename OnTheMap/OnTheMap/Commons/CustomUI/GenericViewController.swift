//
//  GenericViewController.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import UIKit
import MapKit

protocol GenericViewDelegate {
    func didUpdate()
}

class GenericViewController: UIViewController {
    var delegate:GenericViewDelegate?
    let loginService = LoginService()
    let loader = LoaderView()
    
    @IBAction func reloadDataAction(_ sender: Any) {
        getLocations() {
            self.delegate?.didUpdate()
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Do you want Logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.logoutUser()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func logoutUser() {
        UdacityUtils.shared.dispose()
        self.loader.startAnimation(self)
        loginService.deleteSession { result in
            switch result {
            case .Success(let data):
                print(data)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.loader.stopAnimation()
                    self.dismiss(animated: true, completion: nil)
                })
            case .Failure(let error):
                var errorMessage = ""
                if let loginError = error as? ServiceError {
                    errorMessage = loginError.error
                } else {
                    errorMessage = error.localizedDescription
                }
                self.showAlert(errorMessage)
            }
        }
    }
    
    func getLocations(_ completion:(()->())? = nil ) {
        if !loader.isLoading {
            loader.startAnimation(self)
            self.tabBarController?.tabBar.isHidden = true
        }
        loginService.getLocation { results in
            switch results {
            case .Success(let data):
                UdacityUtils.shared.setStudents(students: data.results)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.loader.stopAnimation()
                    self.tabBarController?.tabBar.isHidden = false
                    completion?()
                })
            case .Failure(let error):
                self.showAlert(error.localizedDescription)
            }
        }
    }
    
    func showAlert(_ message:String) {
        let alert = UIAlertController(title: "An error occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async(execute: { () -> Void in
            if self.loader.isLoading {
                self.tabBarController?.tabBar.isHidden = false
                self.loader.stopAnimation()
            }
            self.present(alert, animated: true)
        })
    }
    
}

extension GenericViewController: MKMapViewDelegate {
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let subtitle = view.annotation?.subtitle else  {
                self.showInfo(withMessage: "No link defined.")
                return
            }
            guard let link = subtitle else {
                self.showInfo(withMessage: "No link defined.")
                return
            }
            openWithSafari(link)
        }
    }
}

