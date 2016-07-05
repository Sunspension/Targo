//
//  ViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

import DynamicColor
import SHSPhoneComponent
import BSErrorMessageView
import AlamofireObjectMapper
import RealmSwift
import EZLoadingActivity
import BrightFutures
import Result

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBOutlet weak var phoneNumber: SHSPhoneTextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var verticalSeparator: UIView!
    
    @IBOutlet weak var buttonRegistration: UIButton!
    
    @IBOutlet weak var buttonForgotPassword: UIButton!
    
    @IBOutlet weak var separator: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        separator.backgroundColor = UIColor.lightGrayColor()
        
        phoneNumber.formatter.setDefaultOutputPattern(" (###) ### ####")
        phoneNumber.formatter.prefix = "+7"
        phoneNumber.becomeFirstResponder()
        phoneNumber.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        phoneNumber.textDidChangeBlock = { (textfield: UITextField!) in
            
            if self.phoneNumber.phoneNumber().characters.count < 11 {
                
//                self.buttonLogin.enabled = false
            }
            else {
                
//                self.buttonLogin.enabled = true
                self.password.becomeFirstResponder()
            }
        }
        
        password.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        password.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = DynamicColor(hexString: kHexMainPinkColor)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        if let phone = AppSettings.sharedInstance.lastSessionPhoneNumber {
            
            self.phoneNumber.setFormattedText(String(phone.characters.dropFirst()))
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func registrationAction(sender: AnyObject) {
        
        let controller = self.instantiateViewControllerWithIdentifierOrNibName("RegistrationPhone")
        
        if let phoneRegistration = controller {
            
            self.navigationController?.pushViewController(phoneRegistration, animated: true)
        }
    }
    
    @IBAction func loginAction(sender: AnyObject) {
     
        self.phoneNumber.resignFirstResponder()
        self.password.resignFirstResponder()
        
        let phoneNumber = self.phoneNumber.phoneNumber()
        let code = self.password.text
        
        if ((code?.isEmpty) == nil) {
            
            self.password.bs_setupErrorMessageViewWithMessage("login_empty_code".localized)
            self.password.bs_showError()
            return
        }
        
        Api.userLogin(phoneNumber, code: code!)
            
            .onSuccess { user in
                
                
                
            }.onFailure { eror in
                
                
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        textField.bs_hideError()
        return true
    }
}

