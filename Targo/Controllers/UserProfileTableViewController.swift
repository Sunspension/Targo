//
//  UserProfileTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import AlamofireImage
import SwiftOverlays
import RealmSwift
import Alamofire

private enum ItemTypeEnum {
    
    case UserInfo
    
    case Infromation
    
    case MyCards
    
    case Logout
}


class UserProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var dataSource = TableViewDataSource()
    
    let identifier = "default"
    
    let headerIdentifier = "ProfileHeader"
    
    let userInfo = CollectionSection()
    
    let downloader = ImageDownloader()
    
    var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.setup()
        
        let realm = try! Realm()
        
        if let user = realm.objects(User).first {
            
            self.user = user
        }
        
        Api.sharedInstance.loadCurrentUser()
            
            .onSuccess { user in
            
                self.user = user
                self.tableView.reloadData()
                
                try! realm.write({
                    
                    realm.add(user, update: true)
                })
            }
            .onFailure { error in
            
                print(error)
            }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0 / 255, green: 0 / 255, blue: 80 / 255, alpha: 0.1)
        self.tableView.backgroundView = backgroundView
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .Plain,
                                                                target: nil,
                                                                action: nil)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        self.tableView.registerNib(UINib(nibName: "TUserProfileHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: headerIdentifier)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        let bindingClosure = { (cell: UITableViewCell, item: CollectionSectionItem) in
            
            if (item.itemType as! ItemTypeEnum) != .Logout
                && (item.itemType as! ItemTypeEnum) != .UserInfo {
                
                cell.accessoryType = .DisclosureIndicator
            }
            
            if (item.itemType as! ItemTypeEnum) == .Logout {
                
                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.textColor = UIColor(hexString: kHexMainPinkColor)
            }
            
            cell.textLabel?.text = item.item as? String
        }
        
        userInfo.initializeCellWithReusableIdentifierOrNibName(headerIdentifier,
                                                               item: nil,
                                                               itemType: ItemTypeEnum.UserInfo) { (cell, item) in
        
                                                                let viewCell = cell as! TUserProfileHeaderTableViewCell
                                                                
                                                                viewCell.layoutIfNeeded()
                                                                
                                                                viewCell.selectionStyle = .None
                                                                viewCell.buttonAvatar.addTarget(self,
                                                                                                action: #selector(UserProfileTableViewController.changePhoto),
                                                                                                forControlEvents: .TouchUpInside)
                                                                
                                                                if let user = self.user {
                                                                    
                                                                    if let image = user.image {
                                                                        
                                                                        let urlRequest = NSMutableURLRequest(URL: NSURL(string: image.url)!)
                                                                        
                                                                        let filter = AspectScaledToFillSizeFilter(size: viewCell.imageViewBlur.bounds.size)
                                                                        
                                                                        self.downloader.downloadImage(URLRequest: urlRequest,
                                                                                                 filter: filter,
                                                                                                 completion: { response in
                                                                            
                                                                            guard response.result.error == nil else {
                                                                                
                                                                                return
                                                                            }
                                                                            
                                                                            viewCell.imageViewBlur.image = response.result.value!.applyBlurWithRadius(5,
                                                                                tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4),
                                                                                saturationDeltaFactor: 1,
                                                                                maskImage: nil)
                                                                            
                                                                            viewCell.buttonAvatar.setImage(response.result.value!, forState: .Normal)
                                                                            let layer = viewCell.buttonAvatar.layer
                                                                            layer.borderColor = UIColor.whiteColor().CGColor
                                                                            layer.borderWidth = 2
                                                                        })
                                                                    }
                                                                }
        }
        
        self.dataSource.sections.append(userInfo)
        
        
        let mainSection = CollectionSection()
        self.dataSource.sections.append(mainSection)
        
        mainSection.initializeDefaultCell(identifier,
                                          cellStyle: .Default,
                                          item: "profile_item_my_cards".localized,
                                          itemType: ItemTypeEnum.MyCards,
                                          bindingAction: bindingClosure)
        
        mainSection.initializeDefaultCell(identifier,
                                          cellStyle: .Default,
                                          item: "profile_item_information".localized,
                                          itemType: ItemTypeEnum.Infromation,
                                          bindingAction: bindingClosure)
        
        let logout = CollectionSection()
        self.dataSource.sections.append(logout)
        
        logout.initializeDefaultCell(identifier,
                                     cellStyle: .Default,
                                     item: "profile_item_logout".localized,
                                     itemType: ItemTypeEnum.Logout,
                                     bindingAction: bindingClosure)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = self.dataSource.sections[indexPath.section].items[indexPath.row]
        
        let itemType = item.itemType as! ItemTypeEnum
        
        switch itemType {
            
        case .MyCards:
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("UserCreditCards") {
                
                controller.title = "profile_item_my_cards".localized
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
            
        case .Logout:
         
            Api.sharedInstance.userLogut()
                
                .onSuccess(callback: { success in
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoUserLoggedOutSuccessfully, object: nil))
                
            }).onFailure(callback: { error in
                
                print("User logout error: \(error)")
            })
            
            break
            
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
            
        case 0, 1:
            return 0.01
            
        default:
            return 40
        }
    }
    
    func changePhoto() {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "action_cancel".localized, style: .Cancel, handler: nil)
        
        let choosePhotoAction = UIAlertAction(title: "photo_action_choose".localized, style: .Default) { action in
            
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                
                let library = UIImagePickerController()
                library.sourceType = .PhotoLibrary
                library.navigationBar.barTintColor = UIColor(hexString: kHexMainPinkColor)
                library.navigationBar.tintColor = UIColor.whiteColor()
                library.allowsEditing = true
                library.delegate = self
                
                self.presentViewController(library, animated: true, completion: nil)
            }
            else {
                
                self.showOkAlert("photo_library_unavailable_title".localized,
                                 message: "photo_library_unavailable_message".localized)
            }
        }
        
        let takePhotoAction = UIAlertAction(title: "photo_action_take".localized, style: .Default) { action in
            
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                
                let camera = UIImagePickerController()
                camera.sourceType = .Camera
                camera.allowsEditing = true
                camera.delegate = self
                
                self.presentViewController(camera, animated: true, completion: nil)
            }
            else {
                
                self.showOkAlert("camera_unavailable_title".localized,
                                 message: "camera_unavailable_message".localized)
            }
        }
        
        alert.addAction(choosePhotoAction)
        alert.addAction(takePhotoAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.uploadImage(info)
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Private Methods
    
    func uploadImage(info:[String: AnyObject]) {
        
        let originalImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let rectValue = info["UIImagePickerControllerCropRect"] as? NSValue
        
        if let cropRect = rectValue?.CGRectValue() {
            
            let croppedImage = CGImageCreateWithImageInRect(originalImage.CGImage!, cropRect)
            
            if let cropped = croppedImage {
                
                let finalImage = UIImage(CGImage: cropped)
                
                if let superview = self.view.superview {
                    
                    SwiftOverlays.showCenteredWaitOverlay(superview)
                }
                
                Api.sharedInstance.uploadImage(finalImage)
                    
                    .onSuccess(callback: { uploadResponse in
                        
                        let imageUrlString = uploadResponse.url
                        print(imageUrlString)
                        
                        let realm = try! Realm()
                        if let user = realm.objects(User).first {
                            
                            Api.sharedInstance.applyUserImage(user.id, imageId: uploadResponse.id)
                                
                                .onSuccess(callback: { user in
                                
                                    if let superview = self.view.superview {
                                        
                                        SwiftOverlays.removeAllOverlaysFromView(superview)
                                    }
                                    
                                    if self.userInfo.items.count > 0 {
                                        
                                        let indexPath = self.userInfo.items[0].indexPath
                                        
                                        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? TUserProfileHeaderTableViewCell {
                                            
                                            cell.buttonAvatar.setImage(finalImage, forState: .Normal)
                                            cell.imageViewBlur.image = finalImage.applyBlurWithRadius(5, tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), saturationDeltaFactor: 1, maskImage: nil)
                                        }
                                    }
                                    
                                }).onFailure(callback: { error in
                                    
                                    if let superview = self.view.superview {
                                        
                                        SwiftOverlays.removeAllOverlaysFromView(superview)
                                    }
                                    
                                    print(error)
                                })
                        }
                    })
                    .onFailure(callback: { (error) in
                        
                        if let superview = self.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        
                        print(error)
                    })
            }
        }

    }
    
    // MARK: - Table view data source

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
