//
//  SearchResultsTableViewController.swift
//  Pods
//
//  Created by Toby Applegate on 09/03/2016.
//
//

import UIKit
import SVGKit
import SwiftyJSON

class SearchResultsTableViewController: UITableViewController {
    
    let routeArray = [String]()
    let routeData = RetrieveData()
    var routeAndProvidersInfo = [Dictionary<String, AnyObject>]()
    var passDataDelegate: PassDataProtocol? = nil
    
    let x  = [["hello" : "hello", "test": "test", "json" : 3]] //continue here, to each cell pass data like image url etc and also pass JSON for that route then on map view take the JSON and parse it
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeData.getRoutes({route, providerAttributes in
            
            // Parse JSON
            let parsedData = self.parseJSON(route, providerData: providerAttributes)
            
            // Add parsed data to dict
            self.routeAndProvidersInfo.append(parsedData)


            //reloads tableview on main thread after all data is parsed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let infoDict = routeAndProvidersInfo[indexPath.row]
        //print(infoDict)
        passDataDelegate?.returnDataFromSearch(infoDict)
            

            
        //handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routeAndProvidersInfo.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Get dict corresponding to route selected
        let infoDict = routeAndProvidersInfo[indexPath.row]
        
        cell.textLabel!.text = "\(infoDict["transportType"]!) by \(infoDict["provider"]!)"
        cell.detailTextLabel?.text =  "Will cost \(infoDict["currency"]!)\(infoDict["price"]!)"

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
    func parseJSON(routeData: JSON, providerData: JSON) -> [String:AnyObject] {

        // Dict to hold all the information
        var markerInfoDict = [String:AnyObject]()
        
        // Values for TableView to display route options
        let transportType = routeData["type"].stringValue.stringByReplacingOccurrencesOfString("_", withString: " ")
        let currency = routeData["price"]["currency"].stringValue.currencyFormat()
        let price = routeData["price"]["amount"].stringValue
        let provider  = routeData["provider"].stringValue
        let imageURL = providerData["provider_icon_url"].stringValue
        
        // Assign JSON object to each route in table view so when a cell is selected, the JSON corrisponding to that route is passed abck to the MapVC
        let segments = routeData["segments"].arrayObject
        
        // Put all values in dict
        markerInfoDict["transportType"] = transportType
        markerInfoDict["currency"] = currency
        markerInfoDict["price"] = price
        markerInfoDict["provider"] = provider
        markerInfoDict["imageURL"] = imageURL
        markerInfoDict["segments"] = segments

        return markerInfoDict
    }



}

extension SearchResultsTableViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}
