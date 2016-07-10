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
        
        code.textDidChangeBlock = { (textfield: UITextField!) in
            
            if self.code.phoneNumber().characters.count < 6 {
                
                textfield.rightView = nil
                self.buttonNext.enabled = false
            }
            else {
                
                let image = UIImage(named: "icon-check")
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                imageView.tintColor = DynamicColor(hexString: kHexMainPinkColor)
                textfield.rightViewMode = .Always
                textfield.rightView = imageView
                
                self.buttonNext.enabled = true
            }
        }
        
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
        
        if let phoneNumber = AppSettings.sharedInstance.lastSessionPhoneNumber {
            
            Api.userLogin(phoneNumber, code: self.code.phoneNumber())
                
                .onSuccess { user in
                    
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoUserLoggedInSuccessfully, object: nil))
                    
                    print("User with user id: \(user.id) successfully logged in")
                    
                }.onFailure { error in
                    
                    print(error)
            }
        }
    }
}
