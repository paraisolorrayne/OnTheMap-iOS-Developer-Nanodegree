//
//  LocationListViewController.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import UIKit

class LocationListViewController: GenericViewController {

    // MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension LocationListViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  UdacityUtils.shared.getStudents().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        cell.fill( UdacityUtils.shared.getStudents()[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location =  UdacityUtils.shared.getStudents()[indexPath.row]
        openWithSafari(location.mediaURL ?? "")
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension LocationListViewController:GenericViewDelegate {
    func didUpdate() {
        tableView.reloadData()
    }
}

