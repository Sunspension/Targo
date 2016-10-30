//
//  TSettingsTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import PhoneNumberKit
import SwiftOverlays

private enum ItemTypeEnum {
    
    case fistName
    
    case lastName
    
    case email
    
    case phone
    
    var description: String {
        
        switch self {
            
        case .fistName:
            
            return "settings_user_first_name".localized
            
        case .lastName:
            
            return "settings_user_last_name".localized
            
        case .phone:
            
            return "settings_user_phone".localized
            
        case .email:
            
            return "settings_user_email".localized
        }
    }
}


class TSettingsTableViewController: UITableViewController, UITextFieldDelegate {

    var dataSource = TableViewDataSource()
    
    var user: User!
    
    var editedUser = User()
    
    let realm = try! Realm()
    
    
    deinit {
        
        print("\(typeName(self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.setup()
        self.tableView.tableFooterView = UIView()
        
        self.title = "profile_item_settings".localized
        
        self.tableView.dataSource = self.dataSource
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TSettingsTableViewController.onTapAction))
        self.tableView.addGestureRecognizer(tapGesture)
        
        self.user = self.realm.objects(User.self).first
        
        let personalDataSection = CollectionSection(title: "settings_personal_data_title".localized)
        self.dataSource.sections.append(personalDataSection)
        
        let personalItems = [ItemTypeEnum.fistName, ItemTypeEnum.lastName]
        
        for item in personalItems {
            
            personalDataSection.initializeCellWithReusableIdentifierOrNibName(identifier: "SettingsCell",
                                                                              item: self.user,
                                                                              itemType: item,
                                                                              bindingAction: self.binding)
        }
        
        let contactDataSection = CollectionSection(title: "settings_contact_data_title".localized)
        self.dataSource.sections.append(contactDataSection)
        
        contactDataSection.initializeCellWithReusableIdentifierOrNibName(identifier: "SettingsPhoneCell",
                                                                         item: self.user,
                                                                         itemType: ItemTypeEnum.phone,
                                                                         bindingAction: self.binding)
        
        contactDataSection.initializeCellWithReusableIdentifierOrNibName(identifier: "SettingsCell",
                                                                         item: self.user,
                                                                         itemType: ItemTypeEnum.email,
                                                                         bindingAction: self.binding)
        
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "action_save".localized,
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(TSettingsTableViewController.saveAction))
        
       
    }
    
    func onTapAction() {
        
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return true
    }
    
    func saveAction() {
        
        self.view.endEditing(true)
        
        for section in self.dataSource.sections {
            
            for item in section.items {
                
                let _ = item.validation?()
            }
        }
        
        let user = self.editedUser
        
        if !user.firstName.isEmpty
            || !user.lastName.isEmpty
            || !user.email.isEmpty {
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
            
            Api.sharedInstance.updateUserInformation(userId: self.user!.id,
                                                     firstName: user.firstName,
                                                     lastName: user.lastName,
                                                     email: user.email)
                .onSuccess(callback: { user in
                
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    try! self.realm.write({
                        
                        self.realm.add(user, update: true)
                    })
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kTargoDidUpdateUserProfileNotification), object: nil)
                    
                    let _ = self.navigationController?.popViewController(animated: true)
                })
                .onFailure(callback: { (error) in
                    
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    self.showOkAlert("error".localized, message: "settings_user_update_profile_error".localized)
                    
                    print(error)
                })
        }
        else {
            
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK: - Private methods
    
    fileprivate func binding(_ cell: UITableViewCell, item: CollectionSectionItem) {
        
        cell.selectionStyle = .none
        
        let user = item.item as! User
        
        let type = item.itemType as! ItemTypeEnum
        
        switch type {
            
        case .fistName:
            
            let viewCell = cell as! TSettingsTableViewCell
            viewCell.title.text = type.description
            viewCell.data.text = user.firstName
            viewCell.data.placeholder = type.description
            viewCell.data.delegate = self
            
            item.validation = {
                
                if viewCell.data.text != nil && !viewCell.data.text!.isEmpty {
                    
                    self.editedUser.firstName = viewCell.data.text!
                    
                    return true
                }
                
                return false
            }
            
            break
            
        case .lastName:
            
            let viewCell = cell as! TSettingsTableViewCell
            viewCell.title.text = type.description
            viewCell.data.text = user.lastName
            viewCell.data.placeholder = type.description
            viewCell.data.delegate = self
            
            item.validation = {
                
                if viewCell.data.text != nil && !viewCell.data.text!.isEmpty {
                    
                    self.editedUser.lastName = viewCell.data.text!
                    
                    return true
                }
                
                return false
            }
            
            break
            
        case .phone:
            
            let viewCell = cell as! TSettingsPhoneTableViewCell
            viewCell.title.text = type.description
            viewCell.data.text = String(user.phone.characters.dropFirst())
            viewCell.data.formatter.setDefaultOutputPattern(" (###) ### ####")
            viewCell.data.formatter.prefix = "+7"
            viewCell.data.isUserInteractionEnabled = false
            
            break
            
        case .email:
            
            let viewCell = cell as! TSettingsTableViewCell
            viewCell.title.text = type.description
            viewCell.data.text = user.email
            viewCell.data.placeholder = type.description
            viewCell.data.delegate = self
            
            item.validation = {
                
                if viewCell.data.text != nil && !viewCell.data.text!.isEmpty {
                    
                    self.editedUser.email = viewCell.data.text!
                    
                    return true
                }
                
                return false
            }
            
            break
        }
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
