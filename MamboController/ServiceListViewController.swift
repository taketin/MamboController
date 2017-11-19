//
//  ServiceListViewController.swift
//  MamboController
//
//  Created by taketin on 2017/11/18.
//  Copyright © 2017年 taketin. All rights reserved.
//

import UIKit

class ServiceListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let droneDiscoverer = DroneDiscoverer()
    private var dataSource: [Any] = []
    private var selectedService: ARService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        droneDiscoverer.delegate = self;
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerNotifications()
        droneDiscoverer.startDiscovering()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotifications()
        droneDiscoverer.stopDiscovering()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ServiceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        if let arService = dataSource[indexPath.row] as? ARService {
            let networkType: String!
            switch arService.network_type {
            case ARDISCOVERY_NETWORK_TYPE_NET:
                networkType = "IP (e.g. wifi)"
            case ARDISCOVERY_NETWORK_TYPE_BLE:
                networkType = "BLE"
            case ARDISCOVERY_NETWORK_TYPE_USBMUX:
                networkType = "libmux over USB"
            default:
                networkType = "Unknown"
            }
            
            cell.textLabel?.text = String(format: "%@ on %@ network", arService.name, networkType)
        }
        
        return cell
    }
}

extension ServiceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

// MARK: Private methods

extension ServiceListViewController {
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.enteredBackground),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.enterForeground),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationDidEnterBackground,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationWillEnterForeground,
                                                  object: nil)
    }
    
    @objc private func enterForeground(notification: Notification?) {
        droneDiscoverer.startDiscovering()
    }
    
    @objc private func enteredBackground(notification: Notification?) {
        droneDiscoverer.stopDiscovering()
    }
}

extension ServiceListViewController: DroneDiscovererDelegate {
    func droneDiscoverer(_ droneDiscoverer: DroneDiscoverer!, didUpdateDronesList dronesList: [Any]!) {
        dataSource = dronesList
        tableView.reloadData()
    }
}
