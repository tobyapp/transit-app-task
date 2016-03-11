//
//  FAQViewController.swift
//  transit
//
//  Created by Toby Applegate on 10/03/2016.
//  Copyright © 2015 Toby Applegate. All rights reserved.
//

// View controller for the FAQ view, can add extra functionality later if need to

import UIKit

class FAQViewController: UIViewController{

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Used to display side menu (using SWRevealViewController)
        self.addSideMenu(menuButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
