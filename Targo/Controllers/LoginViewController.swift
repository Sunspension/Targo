//
//  ViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

import DynamicColor

class LoginViewController: UIViewController {

    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var verticalSeparator: UIView!
    
    @IBOutlet weak var buttonRegistration: UIButton!
    
    @IBOutlet weak var buttonForgotPassword: UIButton!
    
    @IBOutlet weak var separator: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        separator.backgroundColor = UIColor.lightGrayColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = DynamicColor(hexString: kHexMainPinkColor)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registrationAction(sender: AnyObject) {
        
        let controller = self.instantiateViewControllerWithIdentifierOrNibName("RegistrationPhone")
        
        if let phoneRegistration = controller {
            
            self.navigationController?.pushViewController(phoneRegistration, animated: true)
        }
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        
    }
}

