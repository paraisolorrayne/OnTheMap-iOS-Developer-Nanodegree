//
//  LocationTableViewCell.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    static let identifier = "\(LocationTableViewCell.self)"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func fill(_ info: StudentInformation) {
        titleLabel.text = (info.firstName ?? "") + " " + (info.lastName ?? "")
        subtitleLabel.text = info.mediaURL
    }
}

