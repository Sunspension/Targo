//
//  ViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

import SHSPhoneComponent
import DynamicColor

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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        separator.backgroundColor = UIColor.lightGray
        
        phoneNumber.formatter.setDefaultOutputPattern(" (###) ### ####")
        phoneNumber.formatter.prefix = "+7"
        phoneNumber.becomeFirstResponder()
        phoneNumber.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        
        phoneNumber.textDidChangeBlock = { textfield in
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.setup()
        
        if let phone = AppSettings.sharedInstance.lastSessionPhoneNumber {
            
            self.phoneNumber.setFormattedText(String(phone.characters.dropFirst()))
            self.password.becomeFirstResponder()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func registrationAction(_ sender: AnyObject) {
        
        let controller = self.instantiateViewControllerWithIdentifierOrNibName("RegistrationPhone")
        
        if let phoneRegistration = controller {
            
            self.navigationController?.pushViewController(phoneRegistration, animated: true)
        }
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
     
        self.phoneNumber.resignFirstResponder()
        self.password.resignFirstResponder()
        
        let phoneNumber = self.phoneNumber.phoneNumber()
        let code = self.password.text
        
//        if ((code?.isEmpty) == nil) {
//            
//            self.password.bs_setupErrorMessageViewWithMessage("login_empty_code".localized)
//            self.password.bs_showError()
//            return
//        }
        
        Api.sharedInstance.userLogin(phoneNumber: phoneNumber!, code: code!)
            
            .onSuccess { user in
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoUserLoggedInSuccessfully)))
                
                print("User with user id: \(user.id) successfully logged in")
                
            }.onFailure { error in
                
                print(error)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
//        textField.bs_hideError()
        return true
    }
}

