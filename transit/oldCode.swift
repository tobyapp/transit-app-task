//
//  oldCode.swift
//  transit
//
//  Created by Toby Applegate on 08/03/2016.
//  Copyright © 2016 Toby Applegate. All rights reserved.
//

import Foundation


//        let svgIcon = SVGKImage(contentsOfURL: url)
//        self.locationMarker.icon = svgIcon.UIImage

//        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) { // 1
//            let svgIcon = SVGKImage(contentsOfURL: url)
//            dispatch_async(dispatch_get_main_queue()) {
//
//                self.locationMarker = GMSMarker(position: coordinate)
//                self.locationMarker.userData = markerInfo
//                self.locationMarker.icon = svgIcon.UIImage
//                self.locationMarker.map = self.mapView
//
//            }
//        }


//        routeData.getImages(markerInfo["iconUrl"]!, resultHandler: ({ image in
//           // print(image)
//            let svgIcon = SVGKImage(source: image as! SVGKSource)
//            self.locationMarker.icon = svgIcon.UIImage
//        }))





//let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//let request: NSURLRequest = NSURLRequest(URL: url!)
//let mainQueue = NSOperationQueue.mainQueue()
//let session = NSURLSession.sharedSession()
//
//NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
//
//    if error == nil && data != nil {
//        
//        
//        // Convert the downloaded data in to a UIImage object
//        let svgIcon = SVGKImage(contentsOfURL: url)
//        
//        dispatch_async(dispatch_get_main_queue(), {
//            self.locationMarker = GMSMarker(position: coordinate)
//            self.locationMarker.userData = markerInfo
//            self.locationMarker.icon = svgIcon.UIImage
//            self.locationMarker.map = self.mapView
//            
//            
//        })
//    }
//    else {
//        print("Error: \(error!.localizedDescription)")
//    }
//})
//



// from table view 

//routeData.getRoutes({route, providerAttributes in
//    
//    let transportType = route["type"].stringValue.stringByReplacingOccurrencesOfString("_", withString: " ")
//    let currency = route["price"]["currency"].stringValue.currencyFormat()
//    let price = route["price"]["amount"].stringValue //route price
//    let provider  = route["provider"].stringValue //route provider
//    let properties = route["properties"] //route properties
//    let imageURL = providerAttributes["provider_icon_url"].stringValue
//    
//    let parsedData = self.parseJSON(route, providerData: providerAttributes)
//    
//    Add info to dict to be accessed in cellForRowAtIndexPath
//    self.routeAndProvidersInfo.append(["price" : price, "provider" : provider, "currency" : currency, "transportType" : transportType, "imageURL" : imageURL])
//    
//    self.routeAndProvidersInfo.append(parsedData)
//    
//    
//    //reloads tableview on main thread after all data is received
//    dispatch_async(dispatch_get_main_queue()) {
//        self.tableView.reloadData()
//    }
//})
//}
//



//        // iterate through differernt segments per route
//        for (_, locations) in segments {
//
//            let polyline = locations["polyline"].stringValue
//            let lineColor = locations["color"].stringValue
//            let travelMode = locations["travel_mode"].stringValue
//            let iconUrl = locations["icon_url"].string
//
//            // iterate through values in each stop
//            for (_, location) in locations["stops"] {
//                let lng = location["lng"].stringValue
//                //print("lng is : \(lng)")
//                let lat = location["lat"].stringValue
//                let dateTime = location["datetime"].stringValue
//                //let markerLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//                let locationName = location["name"].string
//                if let locationName = locationName {
//                    markerInfoDict["locaitonName"] = locationName
//                }
//
//                // Add all parsed data to dict
//                markerInfoDict["transportType"] = transportType
//                markerInfoDict["currency"] = currency
//                markerInfoDict["price"] = price
//                markerInfoDict["provider"] = provider
//                markerInfoDict["imageURL"] = imageURL
//                markerInfoDict["polyline"] = polyline
//                markerInfoDict["markerLng"] = lng
//                markerInfoDict["markerLat"] = lat
//                markerInfoDict["travelMode"] = travelMode
//                markerInfoDict["iconUrl"] = iconUrl
//                markerInfoDict["dateTime"] = dateTime
//                markerInfoDict["polyLine"] = polyline
//                markerInfoDict["lineColor"] = lineColor
//                markerInfoDict["lng"] = lng
//                markerInfoDict["lat"] = lat
//
//            }
//        }



//from vc to get all routes fomr JSON and put them on map

//        var markerInfoDict = [String:String]()
//
//        routeData.getRoutes({route, _ in
//            // each differernt route, 9 in total
//            let segments = route["segments"]
//
//            // iterate through differernt segments per route
//            for (_, locations) in segments {
//
//                let polyline = locations["polyline"].stringValue
//                let lineColor = locations["color"].stringValue
//                let travelMode = locations["travel_mode"].stringValue
//                let iconUrl = locations["icon_url"].string
//
//                // draw polyline on map with color from locations
//                self.drawRoute(polyline, lineColor: lineColor)
//
//                // iterate through values in each stop
//                for (_, location) in locations["stops"] {
//                    let lng = location["lng"].doubleValue
//                    let lat = location["lat"].doubleValue
//                    let dateTime = location["datetime"].stringValue
//                    let locationName = location["name"].stringValue
//
//                    markerInfoDict["locaitonName"] = locationName
//                    markerInfoDict["polyline"] = polyline
//                    markerInfoDict["markerLng"] = "\(lng)"
//                    markerInfoDict["markerLat"] = "\(lat)"
//                    markerInfoDict["travelMode"] = travelMode
//                    markerInfoDict["iconUrl"] = iconUrl
//                    markerInfoDict["dateTime"] = dateTime
//
//                    // obtian coords for marker place marker on map
//                    let markerLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//                    self.placeMarker(markerLocation, markerInfo: markerInfoDict)
//                }
//            }
//
//        })


