//
//  ProfileViewController.swift
//  hitch
//
//  Created by Toby Applegate on 21/12/2015.
//  Copyright © 2015 Toby Applegate. All rights reserved.
//

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
        // Dispose of any resources that can be recreated.
        
    }
    
}
