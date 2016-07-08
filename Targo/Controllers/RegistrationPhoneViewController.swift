//
//  RegistrationViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 02/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireJsonToObjects
import DynamicColor
import SHSPhoneComponent
import EZLoadingActivity

class RegistrationPhoneViewController: UIViewController {
    
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var buttonSend: UIButton!
    
    @IBOutlet weak var phoneNumber: SHSPhoneTextField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        buttonSend.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        buttonSend.enabled = false
        
        self.title = "registration_phone_title".localized
        
        phoneNumber.formatter.setDefaultOutputPattern(" (###) ### ####")
        phoneNumber.formatter.prefix = "+7"
        phoneNumber.becomeFirstResponder()
        phoneNumber.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        phoneNumber.textDidChangeBlock = { (textfield: UITextField!) in
            
            if self.phoneNumber.phoneNumber().characters.count < 11 {
                
                textfield.rightView = nil
                self.buttonSend.enabled = false
            }
            else {
                
                let image = UIImage(named: "icon-check")
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                imageView.tintColor = DynamicColor(hexString: kHexMainPinkColor)
                textfield.rightViewMode = .Always
                textfield.rightView = imageView
                
                self.buttonSend.enabled = true
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func sendAction(sender: AnyObject) {
        
        let phoneNumber = self.phoneNumber.phoneNumber()
        
        EZLoadingActivity.show("Please wait", disableUI: true)
        
        Api.userRegistration(phoneNumber)
            
            .onSuccess { success in
                
                EZLoadingActivity.hide()
                
                let controller = self.instantiateViewControllerWithIdentifierOrNibName("RegistrationCode")
                
                if let phoneRegistration = controller {
                    
                    self.navigationController?.pushViewController(phoneRegistration, animated: true)
                }
                
            }.onFailure { error in
                
                EZLoadingActivity.hide()
                print(error)
        }
    }
}