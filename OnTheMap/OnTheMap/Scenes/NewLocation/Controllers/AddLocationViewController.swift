//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: GenericViewController {

    // MARK: IBOutlets

    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var textFieldLink: UITextField!
    @IBOutlet weak var buttonFindLocation: UIButton!
    
    // MARK: Properties
    lazy var geocoder = CLGeocoder()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.keyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    // MARK: Setup
    private func setUpNavBar(){
        
        textFieldName.delegate = self
        textFieldLink.delegate = self
        textFieldLocation.delegate = self
        //For title in navigation bar
        self.navigationItem.title = "Add Location"
        
        //For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = "CANCEL"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    
    // MARK: IBActions
    
    @IBAction func findLocation(_ sender: Any) {
        guard let location = textFieldLocation.text else {
           return
        }
        
        guard let linkText = textFieldLink.text else {
            return
        }

        let link = "https://\(linkText)"
        
        if location.isEmpty || link.isEmpty {
            showInfo(withMessage: "All fields are required.")
            return
        }
        guard let url = URL(string: link), UIApplication.shared.canOpenURL(url) else {
            showInfo(withMessage: "Please provide a valid link.")
            return
        }
        geocode(location: location)
    }
    
    // MARK: Helpers
    
    private func geocode(location: String) {
        enableControllers(false)
        loader.startAnimation(self)
        geocoder.geocodeAddressString(location) { (placemarkers, error) in
            
            self.enableControllers(true)
            self.performUIUpdatesOnMain {
                self.loader.stopAnimation()
            }
            
            if let error = error {
                self.showInfo(withTitle: "Error", withMessage: "Unable to Forward Geocode Address (\(error))")
            } else {
                var location: CLLocation?
                
                if let placemarks = placemarkers, placemarks.count > 0 {
                    location = placemarks.first?.location
                }
                
                if let location = location {
                    self.syncStudentLocation(location.coordinate)
                } else {
                    self.showInfo(withMessage: "No Matching Location Found")
                }
            }
        }
    }
    
    private func syncStudentLocation(_ coordinate: CLLocationCoordinate2D) {
        self.enableControllers(true)
        
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let viewController = homeStoryboard.instantiateViewController(withIdentifier: "MapPinLocationViewController") as! MapPinLocationViewController
        navigationController?.pushViewController(viewController, animated: true)
        
    }

    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInformation {
        var firstName = ""
        var lastName = ""
        if let textName = textFieldName.text {
            let nameComponents = textName.components(separatedBy: " ")
            firstName = nameComponents.first ?? ""
            lastName = nameComponents.last ?? ""
        }
        
        let studentInfo = [
            "uniqueKey": UdacityUtils.shared.getClient()?.account?.key ?? "AER234",
            "firstName": firstName,
            "lastName":  lastName,
            "mapString": textFieldLocation.text ?? "",
            "mediaURL": textFieldLink.text ?? "",
            "latitude": Float(coordinate.latitude),
            "longitude": Float(coordinate.longitude),
            ] as [String: AnyObject]
        
        let student = StudentInformation(studentInfo)
        return student
    }
    
    private func enableControllers(_ enable: Bool) {
        self.enableUI(views: textFieldLocation, textFieldLink, buttonFindLocation, enable: enable)
    }
    
}

// MARK: TextField Delegate
extension AddLocationViewController: UITextFieldDelegate  {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
