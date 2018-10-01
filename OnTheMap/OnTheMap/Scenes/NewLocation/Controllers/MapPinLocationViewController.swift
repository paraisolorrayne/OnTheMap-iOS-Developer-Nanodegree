//
//  MapPinLocationViewController.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapPinLocationViewController: GenericViewController {

    // MARK: IBOutlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonSend: UIButton!

    // MARK: Properties

    let studentService = StudentService()
    var studentInformation: StudentInformation?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if let studentLocation = studentInformation {
            showLocations(student: studentLocation)
        }
    }

    // MARK: IBActions

    @IBAction func send(_ sender: Any) {
        if let studentLocation = studentInformation {
            loader.startAnimation(self)
            studentService.postStudentLocation(student: studentLocation) { result in
                switch result {
                case .Success(let data):
                    print(data)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.loader.stopAnimation()
                        self.handleSyncLocationResponse(error: nil)
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
    }

    // MARK: Business Logic

    private func showLocations(student: StudentInformation) {
        if let firstName = student.firstName, let lastName = student.lastName, let latitude = student.latitude, let longitude = student.longitude {
            let annotation = MKPointAnnotation()
            let lat = CLLocationDegrees(latitude)
            let long = CLLocationDegrees(longitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = firstName + " " + lastName
            annotation.subtitle = student.mediaURL
            self.mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    private func extractCoordinate(location: StudentInformation) -> CLLocationCoordinate2D? {
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
        }
        return nil
    }
    
    private func handleSyncLocationResponse(error: NSError?) {
        if let error = error {
            self.showInfo(withTitle: "Error", withMessage: error.localizedDescription)
        } else {
            self.showInfo(withTitle: "Success", withMessage: "Student Location updated!", action: {
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: .reload, object: nil)
            })
        }
    }
}

// MARK: Extension
extension Notification.Name {
    static let reload = Notification.Name("reload")
}

