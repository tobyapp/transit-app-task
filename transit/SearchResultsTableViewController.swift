//
//  SearchResultsTableViewController.swift
//  Pods
//
//  Created by Toby Applegate on 09/03/2016.
//

// VC to display routes avalible for selection

import UIKit
import SVGKit
import SwiftyJSON

class SearchResultsTableViewController: UITableViewController {
    
    let routeArray = [String]()
    let routeData = RetrieveData()
    var routeAndProvidersInfo = [Dictionary<String, AnyObject>]()
    var providerInfo = [JSON]()
    var passDataDelegate: PassDataProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeData.getRoutes({route, providerAttributes in
            
            // Parse JSON
            let (parsedData, providerInformation) = self.parseJSON(route, providerData: providerAttributes)
            
            // Add parsed data to dict and array
            self.routeAndProvidersInfo.append(parsedData)
            self.providerInfo.append(providerInformation)

            //reloads tableview on main thread after all data is parsed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Route data corrisponding to the cell selected
        let routeData = routeAndProvidersInfo[indexPath.row]
        
        // Provider data corrisponding to the cell selected
        let providerData = providerInfo[indexPath.row]

        // Pass data back to map VC
        passDataDelegate?.returnDataFromSearch(routeData, providerData: providerData)
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeAndProvidersInfo.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Get dict corresponding to route selected
        let infoDict = routeAndProvidersInfo[indexPath.row]
        
        cell.textLabel!.text = "\(infoDict["transportType"]!) by \(infoDict["provider"]!)"
        
        // If equals EUR then no cost was given in JSON file
        if "\(infoDict["currency"]!)" == "EUR" {
            cell.detailTextLabel?.text = "No cost avalible"
        }
        else {
            cell.detailTextLabel?.text =  "Will cost \(infoDict["currency"]!)\(infoDict["price"]!)"
        }

        // Access data form URL
        let url = NSURL(string: infoDict["imageURL"]! as! String)
        let session = NSURLSession.sharedSession()
        
        // Perform background download of content form the URL
        let task = session.dataTaskWithURL(url!, completionHandler: { (response, data, error) in
            
            if error == nil && response != nil {
                
                // Image from URL is SVG so use external framework (SVGKit) to use image
                let svgIcon = SVGKImage(data: response)
                
                // Assign image to cell's image and reload table view on main thread
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageView!.image = svgIcon.UIImage
                    self.tableView.reloadData()
                })
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        task.resume()
        
        return cell
    }

    // Function to parse JSON
    func parseJSON(routeData: JSON, providerData: JSON) -> ([String:AnyObject], JSON) {

        // Dict to hold all the information
        var markerInfoDict = [String:AnyObject]()
        
        // Values for TableView to display route options
        let transportType = routeData["type"].stringValue.stringByReplacingOccurrencesOfString("_", withString: " ")
        let currency = routeData["price"]["currency"].stringValue.currencyFormat()
        let price = routeData["price"]["amount"].stringValue
        let provider  = routeData["provider"].stringValue
        let imageURL = providerData["provider_icon_url"].stringValue
        let providerInformation = routeData["properties"]

        // Assign JSON object to each route in table view so when a cell is selected, the JSON corrisponding to that route is passed abck to the MapVC
        let segments = routeData["segments"].arrayObject

        // Put all values in dict
        markerInfoDict["transportType"] = transportType
        markerInfoDict["currency"] = currency
        markerInfoDict["price"] = price
        markerInfoDict["provider"] = provider
        markerInfoDict["imageURL"] = imageURL
        markerInfoDict["segments"] = segments

        return (markerInfoDict, providerInformation)
    }

}
