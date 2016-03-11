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
import SVGKit
import UIKit

class RetrieveData {
    let url = "https://raw.githubusercontent.com/allyapp/transit-app-task/master/data.json"
    
    //Get JSON, and give results back to view controller
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
    
}