//
//  RegistrationCodeViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 03/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import SHSPhoneComponent
import DynamicColor

class RegistrationCodeViewController: UIViewController {

    @IBOutlet weak var code: SHSPhoneTextField!

    @IBOutlet weak var buttonNext: UIButton!
    
    @IBOutlet weak var separator: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonNext.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        self.title = "registration_phone_title".localized
        
        code.formatter.setDefaultOutputPattern("######")
        code.becomeFirstResponder()
        code.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        
        separator.backgroundColor = UIColor.lightGrayColor()
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false;
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = true;
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        
        
    }
}
