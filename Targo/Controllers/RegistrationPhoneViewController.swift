//
//  RegistrationViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 02/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Alamofire
import DynamicColor
import SHSPhoneComponent
import SwiftOverlays
import ReactiveKit

class RegistrationPhoneViewController: UIViewController {
    
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var buttonSend: UIButton!
    
    @IBOutlet weak var phoneNumber: SHSPhoneTextField!
    
    @IBOutlet weak var buttonUserAgreement: UIButton!
    
    var disposable: Disposable?
    
    deinit {
        
        disposable?.dispose()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        buttonSend.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        buttonSend.isEnabled = false
        
        self.title = "registration_phone_title".localized
        
        phoneNumber.formatter.setDefaultOutputPattern(" (###) ### ####")
        phoneNumber.formatter.prefix = "+7"
        phoneNumber.becomeFirstResponder()
        phoneNumber.tintColor = DynamicColor(hexString: kHexMainPinkColor)
        phoneNumber.textDidChangeBlock = { textfield in
            
            if self.phoneNumber.phoneNumber().characters.count < 11 {
                
                textfield!.rightView = nil
                self.buttonSend.isEnabled = false
            }
            else {
                
                let image = UIImage(named: "icon-check")
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                imageView.tintColor = DynamicColor(hexString: kHexMainPinkColor)
                textfield!.rightViewMode = .always
                textfield!.rightView = imageView
                
                self.buttonSend.isEnabled = true
            }
        }
        
        separator.backgroundColor = UIColor.lightGray
        
        let string1 = "user_registration_confidential_part1".localized
        
        let attributedString1 = NSMutableAttributedString(string: string1, attributes: [NSForegroundColorAttributeName : UIColor.black])
        
        let string2 = "user_registration_confidential_part2".localized
        
        let attributedString2 = NSMutableAttributedString(string: string2, attributes: [NSForegroundColorAttributeName : UIColor(hexString: kHexMainPinkColor)])
        
        attributedString1.append(attributedString2)
        
        buttonUserAgreement.setAttributedTitle(attributedString1, for: .normal)
        buttonUserAgreement.titleLabel?.textAlignment = .center
        
        self.disposable = buttonUserAgreement.bnd_tap.observeNext {
            
            if let path = Bundle.main.path(forResource: "agreement", ofType: "docx") {
                
                let controller = TWebViewController.controllerInstance(url: URL(fileURLWithPath: path))
                controller.title = "user_agreement_title".localized
                let navigationController = UINavigationController(rootViewController: controller)
                
                self.present(navigationController, animated: true, completion: nil)
            }
        }
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
    
    @IBAction func sendAction(_ sender: AnyObject) {
        
        let phoneNumber = self.phoneNumber.phoneNumber()
        
        showWaitOverlay()
        
        Api.sharedInstance.userRegistration(phoneNumber: phoneNumber!)
            
            .onSuccess {[weak self] response in
                
                self?.removeAllOverlays()
                
                AppSettings.sharedInstance.lastSessionPhoneNumber = phoneNumber
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: kTargoCodeSent)
                defaults.synchronize()
                
                let controller = self?.instantiateViewControllerWithIdentifierOrNibName("RegistrationCode")
                
                if let phoneRegistration = controller {
                    
                    self?.navigationController?.pushViewController(phoneRegistration, animated: true)
                }
                
            }.onFailure {[weak self] error in
                
                self?.removeAllOverlays()
                
                let alert = UIAlertController(title: "Error", message: error.message, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
        }
    }
}
