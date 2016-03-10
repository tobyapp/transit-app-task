//
//  ExtensionsAndProtocols.swift
//  transit
//
//  Created by Toby Applegate on 10/03/2016.
//  Copyright © 2016 Toby Applegate. All rights reserved.
//

import Foundation


extension String {
    // Convert currency abbreviation to symbol
    func currencyFormat() -> String {
        switch self {
        case "EUR":
            return "€"
        case "USD", "AUD", "CAD":
            return "$"
        case "GBP":
            return "£"
        default:
            return "EUR"
        }
    }
}

extension UIColor {
    // convert HEX string to RGB color to be used for polyline color
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

// Protocol to send data between VC's
protocol PassDataProtocol {
    func returnDataFromSearch(data: [String: AnyObject])
}


extension UIViewController {
    
    // Default color scheme across application
    var purple: UIColor {
        return UIColor(red: 103/255, green: 58/255, blue: 183/255, alpha: 1)
    }
    
    // Adds side menu to view controllers
    func addSideMenu(menuButton : UIBarButtonItem!) {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = CGFloat(200)
            self.revealViewController().frontViewShadowRadius = CGFloat(50)
            self.revealViewController().frontViewShadowOffset = CGSizeMake(CGFloat(0), CGFloat(5))
            self.revealViewController().frontViewShadowOpacity = CGFloat(1)
            self.revealViewController().frontViewShadowColor = UIColor.darkGrayColor()
            changeColorScheme()
        }
    }
    
    // Change color scheme of navigation menu etc
    func changeColorScheme(){
        self.navigationController?.navigationBar.barTintColor = purple
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
    }
}