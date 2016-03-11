//
//  RetrieveData.swift
//  transit
//
//  Created by Toby Applegate on 07/03/2016.
//  Copyright © 2016 Toby Applegate. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import AlamofireImage
import SVGKit
import UIKit

class RetrieveData {
    let url = "https://raw.githubusercontent.com/allyapp/transit-app-task/master/data.json"
    
    //Get JSON, parse it, and give results back to view controller
    func getRoutes(resultHandler: (routes: JSON, providerAttributes: JSON) -> ()){
        Alamofire.request(.GET, url).responseJSON { Response in
            switch Response.result {
            case .Success(let data):

                let json = JSON(data)
                
                // Get the info about the differernt providers
                let providers = json["provider_attributes"]
                
                guard let routes = json["routes"].array else {
                    print("No routes")
                    return
                }
                
                for route in routes {
                    for (name, provider) in providers {

                        // return provider of route and info about provider from 'providers' JSON
                        // checks both matches to return the right information about each route
                        if route["provider"].stringValue == name {
                            resultHandler(routes: route, providerAttributes: provider)
                        }
                    }
                }

            case .Failure(let error):
                print("Error in gettins route data : \(error.localizedDescription)")
            }
        }
    }
    
    //Get JSON, parse it, and give results back to view controller
    func getRoutesTest(resultHandler: (routeData: [String:String]) -> ()){
        Alamofire.request(.GET, url).responseJSON { Response in
            switch Response.result {
            case .Success(let data):
                
                let json = JSON(data)
                
                // Get the info about the differernt providers
                let providers = json["provider_attributes"]
                
                guard let routes = json["routes"].array else {
                    print("No routes")
                    return
                }
                
                for route in routes {
                    for (name, _) in providers {
                        
                        // return provider of route and info about provider from 'providers' JSON
                        // checks both matches to return the right information about each route
                        if route["provider"].stringValue == name {
                            let routeInfo = self.parseJSON(routes[8])
                            resultHandler(routeData: routeInfo)
                        }
                    }
                }
                
            case .Failure(let error):
                print("Error in gettins route data : \(error.localizedDescription)")
            }
        }
    }
    
    func parseJSON(data: JSON) -> [String:String] {
        
        // dict to hold all the information
        var markerInfoDict = [String:String]()
        
        // each differernt route, 9 in total
        let segments = data["segments"]
        
        // iterate through differernt segments per route
        for (_, locations) in segments {
            
            let polyline = locations["polyline"].stringValue
            let lineColor = locations["color"].stringValue
            let travelMode = locations["travel_mode"].stringValue
            let iconUrl = locations["icon_url"].string
            
            // draw polyline on map with color from locations
            //self.drawRoute(polyline, lineColor: lineColor)
            
            // iterate through values in each stop
            for (_, location) in locations["stops"] {
                let lng = location["lng"].stringValue
                let lat = location["lat"].stringValue
                let dateTime = location["datetime"].stringValue
                //let markerLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let locationName = location["name"].string
                if let locationName = locationName {
                    markerInfoDict["locaitonName"] = locationName
                }
                markerInfoDict["polyline"] = polyline
                markerInfoDict["markerLng"] = "\(lng)"
                markerInfoDict["markerLat"] = "\(lat)"
                markerInfoDict["travelMode"] = travelMode
                markerInfoDict["iconUrl"] = iconUrl
                markerInfoDict["dateTime"] = dateTime
                markerInfoDict["polyLine"] = polyline
                markerInfoDict["lineColor"] = lineColor
                markerInfoDict["lng"] = lng
                markerInfoDict["lat"] = lat
                //self.placeMarker(markerLocation, markerInfo: markerInfoDict)
                
                //need to convert lng and lat back to doubles and create new marker location
            }
        }
        return markerInfoDict
    }

    func getImages(imageURL: String, resultHandler: (image: AnyObject) -> ()){
        
        Alamofire.request(.GET, imageURL)
            .responseImage { response in
                debugPrint(response)
                
                print(response.request)
                print(response.response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    resultHandler(image: image)
                }
        }
//        let url = NSURL(string: markerInfo["iconUrl"]!)
//        
//        let svgIcon = SVGKImage(contentsOfURL: url)
//        let x = svgIcon
//        
//        self.locationMarker.icon = svgIcon.UIImage
        
    }

}