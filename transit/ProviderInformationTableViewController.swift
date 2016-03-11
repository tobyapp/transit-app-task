//
//  ProviderInformationTableViewController.swift
//  transit
//
//  Created by Toby Applegate on 10/03/2016.
//  Copyright © 2016 Toby Applegate. All rights reserved.

// VC to display info about the provider of each route (such as phone number for example)

import UIKit
import SwiftyJSON

class ProviderInformationTableViewController: UITableViewController {
    
    var providerJSON: JSON?
    var providerInfo = [String]()
    var providerDetail = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Unwraps JSON as no info about provider could exist
        if let providerJSON = providerJSON {
            parseJSON(providerJSON)
        }
    }
    
    // Function to parse JSON
    func parseJSON(data: JSON) {

        // Test to see if JSON contians data
        let testJSON = "\(data)"

        // JSON contains data
        if testJSON != "null" {
            
            // Values to check what provider info has been passed
            let taxiCompanies = data["companies"]
            let bikeInfo = data["available_bikes"]
            let carInfo = data["model"]
            
            if taxiCompanies != nil {
                for (_, taxi) in taxiCompanies {
                    print("taxi : \(taxi)")
                    providerInfo.append(taxi["name"].stringValue)
                    providerDetail.append(taxi["phone"].stringValue)
                }
            }
            
            else if carInfo != nil {
                providerInfo.append("Model : \(data["model"].stringValue)")
                providerInfo.append("License Plate: \(data["license_plate"].stringValue)")
                
                // Description may be empty depending on the info available about the provider from the JSON
                let description = data["description"].stringValue
                if description != "" {
                    providerInfo.append("Description : \(description)")
                }
            }
            
            else if bikeInfo != nil {
                providerInfo.append("Num of available bikes : \(data["available_bikes"].stringValue)")
            }
        }
        else {
            print("No information available")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerInfo.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel!.text = providerInfo[indexPath.item]
        
        // Checks to see if there is any extra info to put in each cell (such as phone number)
        if providerDetail.count != 0 {
            cell.detailTextLabel?.text = "Number : \(providerDetail[indexPath.item])"
        }
        else {
            cell.detailTextLabel?.text =  ""
        }
        
        return cell
    }

}
