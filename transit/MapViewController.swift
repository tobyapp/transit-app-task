//
//  MapViewController.swift
//  transit
//
//  Created by Toby Applegate on 07/03/2016.
//  Copyright © 2016 Toby Applegate. All rights reserved.
//

// VC to display google maps and to show routes selected etc

import UIKit
import GoogleMaps
import SVGKit
import SwiftyJSON

class MapViewController: UIViewController, GMSMapViewDelegate, PassDataProtocol {

    var locationMarker: GMSMarker!
    let routeData = RetrieveData()
    var routePath: GMSPolyline? // Var to store last plooted route
    var searchResultsController: UISearchController? = nil
    var plottedByRoute = false
    var providerInformationJSON: JSON?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add menu button to side menu
        addSideMenu(menuButton)
        
        self.view.backgroundColor = purple
        
        // Add bar button to nav bar
        let providerButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "showProviderInformation")
        navigationItem.rightBarButtonItem = providerButton
        
        // Initalize search table VC
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("SearchResultsTableViewController") as! SearchResultsTableViewController
        searchResultsController = UISearchController(searchResultsController: locationSearchTable)
        searchResultsController?.searchResultsUpdater = locationSearchTable
        
        locationSearchTable.passDataDelegate = self
        
        // Set properties fo search bar
        let searchBar = searchResultsController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Enter Location"
        navigationItem.titleView = searchResultsController?.searchBar
        searchResultsController?.hidesNavigationBarDuringPresentation = false
        searchResultsController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        self.mapView.delegate = self
        mapView.settings.compassButton = true
        
        // position map camera
        let position = CLLocationCoordinate2DMake(52.5243700, 13.4105300)
        mapView.camera = GMSCameraPosition(target: position, zoom: 14, bearing: 0, viewingAngle: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Function to parse JSON data
    func parseJSON(data: JSON) {
        
        // Dict to hold all the information
        var markerInfoDict = [String:String]()
        
        // Iterate through differernt locations (segments) per route
        for (_, locations) in data {

            let polyline = locations["polyline"].stringValue
            let lineColor = locations["color"].stringValue
            let travelMode = locations["travel_mode"].stringValue
            let iconUrl = locations["icon_url"].string
            
            // Draw polyline on map with color from locations
            drawRoute(polyline, lineColor: lineColor)

            // Iterate through values in each stop
            for (_, location) in locations["stops"] {
                
                let lng = location["lng"].doubleValue
                let lat = location["lat"].doubleValue
                let dateTime = location["datetime"].stringValue
                let locationName = location["name"].stringValue
                
                // Assign values in dict
                markerInfoDict["locaitonName"] = locationName
                markerInfoDict["polyline"] = polyline
                markerInfoDict["markerLng"] = "\(lng)"
                markerInfoDict["markerLat"] = "\(lat)"
                markerInfoDict["travelMode"] = travelMode
                markerInfoDict["iconUrl"] = iconUrl
                markerInfoDict["dateTime"] = dateTime
                
                // obtian coords for marker and place marker on map
                let markerLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                placeMarker(markerLocation, markerInfo: markerInfoDict)
            }
        }
    }

    // Places marker on map from JSON
    func placeMarker(coordinate: CLLocationCoordinate2D, markerInfo: [String: String]) {
        
        // Access data form URL
        let url = NSURL(string: markerInfo["iconUrl"]!)
        let session = NSURLSession.sharedSession()
        
        // Perform background download of content form the URL
        let task = session.dataTaskWithURL(url!, completionHandler: { (response, data, error) in

            if error == nil && response != nil {
                
                // Image from URL is SVG so use external framework (SVGKit) to use image
                let svgIcon = SVGKImage(data: response)
                
                // Place markers with custom image and reload markers on main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.locationMarker = GMSMarker(position: coordinate)
                    self.locationMarker.userData = markerInfo
                    self.locationMarker.icon = svgIcon.UIImage
                    self.locationMarker.appearAnimation = kGMSMarkerAnimationPop
                    self.locationMarker.map = self.mapView
                })
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        task.resume()
    }
    
    
    // Draws route on map (color changes depending if selected by user)
    func drawRoute(route: String, lineColor: String) {
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        let routePolyline = GMSPolyline(path: path)
        let polyLineColour = GMSStrokeStyle.solidColor(UIColor(hexString: lineColor)) // Convert color using extension
        routePolyline.spans = [GMSStyleSpan(style: polyLineColour)]
        routePolyline.strokeWidth = 5.0
        routePolyline.map = mapView
        routePath = routePolyline
    }

    // called when marker tapped
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        // Get coords of marker
        let lat = marker.userData!["markerLat"] as! String
        let lng = marker.userData!["markerLng"] as! String
        
        // Place camera position to marker
        let currentZoom = self.mapView.camera.zoom
        let markerLocation = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lng)!)
        mapView.camera = GMSCameraPosition(target: markerLocation, zoom: currentZoom, bearing: 0, viewingAngle: 0)
        
        // Removes highlighted line if one exists
        if plottedByRoute {
            removeHighlight()
        }
        
        // Highlight selected route in a differernt color
        let polyLine = marker.userData!["polyline"] as! String
        drawRoute(polyLine, lineColor: "#006600")
        plottedByRoute = true
        
        // Return false so map can continue with its default selection behavior
        return false
    }
    
    // Presents custom window info box above marker
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow : MarkerInfoWindow = NSBundle.mainBundle().loadNibNamed("MarkerInfoWindow", owner: self, options: nil).first! as! MarkerInfoWindow
 
        infoWindow.layer.cornerRadius = 10
            
        let locaitonName = marker.userData!["locaitonName"] as! String
        let travelMode = marker.userData!["travelMode"] as! String
        let dateTime = marker.userData!["dateTime"] as! String
        let formattedDate = formatDate(dateTime)
            
        infoWindow.infoLabel.text = "\(travelMode) to \(locaitonName) @ \(formattedDate)"
            
        return infoWindow
    }

    // format time and date from JSON
    func formatDate(dateTime: String) -> String {
        
        let jsonDateFormatter = NSDateFormatter()
        // format JSON date
        jsonDateFormatter.dateFormat = "yyy-MM-dd'T'HH:mm:ss+SS:SS"
        // convert to NSDate?
        let dateFromJSON = jsonDateFormatter.dateFromString(dateTime)
        
        let dateStringFormatter = NSDateFormatter()
        // format NSDate? above to differernt format
        dateStringFormatter.dateFormat = "HH:mm 'on' yyy-MM-dd"
        // convert to String
        let formattedDate = dateStringFormatter.stringFromDate(dateFromJSON!)
        
        return formattedDate
    }
    
    // Called when user tapps the map (but not on a marker)
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        // If rotue highlighted by user, remove highlight
        if plottedByRoute {
            removeHighlight()
            plottedByRoute = false
        }

        let currentZoom = self.mapView.camera.zoom
        mapView.camera = GMSCameraPosition(target: coordinate, zoom: currentZoom, bearing: 0, viewingAngle: 0)
    }
    
    // Removes highlighted polyline
    func removeHighlight(){
        // removes previously plotted line form the map
        if let routePath = routePath {
            routePath.map = nil
        }
    }

    // Function from protocol to recieve data from table view containing routes + provider info
    func returnDataFromSearch(routeData: [String: AnyObject], providerData: JSON) {
        
        // Clear map of previously plotted routes
        mapView.clear()
        
        // Get JSON from dict
        let segments = JSON(routeData["segments"]!)
        
        // Parse JSON and display routes and markers on map
        parseJSON(segments)
        
        // Set variable to contain JSON about the provider of each route
        providerInformationJSON = providerData
    }
    
    // Function to segue to provider info TableVC
    func showProviderInformation() {
        performSegueWithIdentifier("segueToProviderInfoTableVC", sender: nil)
    }
    
    // Pass data (JSON) to tableVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segueToProviderInfoTableVC") {
            if let destinationViewController = segue.destinationViewController as? ProviderInformationTableViewController {
                if let providerInformationJSON = providerInformationJSON {
                    destinationViewController.providerJSON = providerInformationJSON
                }
            }
        }
    }

    
}
