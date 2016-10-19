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
        
//        self.setup()
        
        buttonNext.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        self.title = "registration_phone_title".localized
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        code.formatter.setDefaultOutputPattern("######")
        code.becomeFirstResponder()
        code.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        
        code.textDidChangeBlock = { textfield in
            
            if self.code.phoneNumber().characters.count < 6 {
                
                textfield?.rightView = nil
                self.buttonNext.isEnabled = false
            }
            else {
                
                let image = UIImage(named: "icon-check")
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                imageView.tintColor = DynamicColor(hexString: kHexMainPinkColor)
                textfield?.rightViewMode = .always
                textfield?.rightView = imageView
                
                self.buttonNext.isEnabled = true
            }
        }
        
        separator.backgroundColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func nextAction(_ sender: AnyObject) {
        
        if let phoneNumber = AppSettings.sharedInstance.lastSessionPhoneNumber {
            
            showWaitOverlay()
            
            Api.sharedInstance.userLogin(phoneNumber: phoneNumber, code: self.code.phoneNumber())
                
                .onSuccess { [weak self] user in
                    
                    self?.removeAllOverlays()
                    
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoUserLoggedInSuccessfully)))
                    
                    print("User with user id: \(user.id) successfully logged in")
                    
                }.onFailure { [weak self] error in
                    
                    self?.removeAllOverlays()
                    
                    self?.showError(error.message)
            }
        }
    }
    
    @IBAction func sendCodeAction(_ sender: AnyObject) {
        
        if let phoneNumber = AppSettings.sharedInstance.lastSessionPhoneNumber {
            
            showWaitOverlay()
            
            Api.sharedInstance.userRegistration(phoneNumber: phoneNumber)
                
                .onSuccess { [weak self] response in
                    
                    self?.removeAllOverlays()
                    
                }.onFailure { [weak self] error in
                    
                    self?.removeAllOverlays()
                    
                    self?.showError(error.message)
            }
        }
    }
    
    fileprivate func showError(_ errorMessage: String) {
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
