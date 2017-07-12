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

private enum ItemTypeEnum {
    
    case userInfo
    
    case information
    
    case myCards
    
    case logout
    
    case settings
}


class UserProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var dataSource = TableViewDataSource()
    
    let identifier = "default"
    
    let headerIdentifier = "ProfileHeader"
    
    let userInfo = CollectionSection()
    
    let downloader = ImageDownloader()
    
    var user: User?
    
    let realm = try! Realm()
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.setup()
        
        if let user = realm.objects(User.self).first {
            
            self.user = user
        }
        
        Api.sharedInstance.loadCurrentUser()
            
            .onSuccess { user in
            
                self.user = user
                self.tableView.reloadData()
                
                try! self.realm.write({
                    
                    self.realm.add(user, update: true)
                })
            }
            .onFailure { error in
            
                print(error)
            }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: kHexTableViewBackground)
        self.tableView.backgroundView = backgroundView
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        self.tableView.register(UINib(nibName: "TUserProfileHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: headerIdentifier)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let bindingClosure = { (cell: UITableViewCell, item: CollectionSectionItem) in
            
            if (item.itemType as! ItemTypeEnum) != .logout
                && (item.itemType as! ItemTypeEnum) != .userInfo {
                
                cell.accessoryType = .disclosureIndicator
            }
            
            if (item.itemType as! ItemTypeEnum) == .logout {
                
//                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.textColor = UIColor(hexString: kHexMainPinkColor)
            }
            
            cell.textLabel?.text = item.item as? String
        }
        
        userInfo.initializeItem(reusableIdentifierOrNibName: headerIdentifier,
                                item: nil,
                                itemType: ItemTypeEnum.userInfo,
                                bindingAction: headerCellBinding)
        self.dataSource.sections.append(userInfo)
        
        
        let mainSection = CollectionSection()
        self.dataSource.sections.append(mainSection)
        
        mainSection.initializeItem(reusableIdentifier: identifier,
                                   cellStyle: .default,
                                   item: "profile_item_my_cards".localized,
                                   itemType: ItemTypeEnum.myCards,
                                   bindingAction: bindingClosure)
        
        mainSection.initializeItem(reusableIdentifier: identifier,
                                   cellStyle: .default,
                                   item: "profile_item_information".localized,
                                   itemType: ItemTypeEnum.information,
                                   bindingAction: bindingClosure)
        
        mainSection.initializeItem(reusableIdentifier: identifier,
                                   cellStyle: .default,
                                   item: "profile_item_settings".localized,
                                   itemType: ItemTypeEnum.settings,
                                   bindingAction: bindingClosure)
        
        let logout = CollectionSection()
        self.dataSource.sections.append(logout)
        
        logout.initializeItem(reusableIdentifier: identifier,
                              cellStyle: .default,
                              item: "profile_item_logout".localized,
                              itemType: ItemTypeEnum.logout,
                              bindingAction: bindingClosure)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onUserDidUpdateNotification),
                                               name: NSNotification.Name(rawValue: kTargoDidUpdateUserProfileNotification),
                                               object: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.dataSource.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        let itemType = item.itemType as! ItemTypeEnum
        
        switch itemType {
            
        case .myCards:
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("UserCreditCards") {
                
                controller.title = "profile_item_my_cards".localized
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
            
        case .information:
            
            self.t_router_openInformationController()
            break
            
        case .settings:
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("EditSetting") {
                
                controller.title = "profile_item_my_cards".localized
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
            
        case .logout:
         
            Api.sharedInstance.userLogut()
                
                .onSuccess(callback: { success in
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoUserLoggedOutSuccessfully), object: nil))
                
            }).onFailure(callback: { error in
                
                print("User logout error: \(error)")
            })
            
            break
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
            
        case 0, 1:
            return 0.01
            
        default:
            return 40
        }
    }
    
    func onUserDidUpdateNotification() {
        
        self.user = self.realm.objects(User.self).last
        self.tableView.reloadData()
    }
    
    func changePhoto() {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "action_cancel".localized, style: .cancel, handler: nil)
        
        let choosePhotoAction = UIAlertAction(title: "photo_action_choose".localized, style: .default) { action in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                let library = UIImagePickerController()
                library.sourceType = .photoLibrary
                library.navigationBar.barTintColor = UIColor(hexString: kHexMainPinkColor)
                library.navigationBar.tintColor = UIColor.white
                library.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
                library.allowsEditing = true
                library.delegate = self
                
                self.present(library, animated: true, completion: nil)
            }
            else {
                
                self.showOkAlert("photo_library_unavailable_title".localized,
                                 message: "photo_library_unavailable_message".localized)
            }
        }
        
        let takePhotoAction = UIAlertAction(title: "photo_action_take".localized, style: .default) { action in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                let camera = UIImagePickerController()
                camera.sourceType = .camera
                camera.allowsEditing = true
                camera.delegate = self
                
                self.present(camera, animated: true, completion: nil)
            }
            else {
                
                self.showOkAlert("camera_unavailable_title".localized,
                                 message: "camera_unavailable_message".localized)
            }
        }
        
        alert.addAction(choosePhotoAction)
        alert.addAction(takePhotoAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.uploadImage(info as [String : AnyObject])
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }

    //MARK: - Private Methods
    
    fileprivate func headerCellBinding(_ cell: UITableViewCell, _ item: CollectionSectionItem) {
        
        let viewCell = cell as! TUserProfileHeaderTableViewCell
        
//        viewCell.layoutIfNeeded()
        
        viewCell.selectionStyle = .none
        viewCell.buttonAvatar.addTarget(self,
                                        action: #selector(self.changePhoto),
                                        for: .touchUpInside)
        
        if let user = self.user {
            
            viewCell.labelUserName.text = user.firstName + " " + user.lastName
            
            if let image = user.image {
                
                let urlRequest = URLRequest(url: URL(string: image.url)!)
                
                let filter = AspectScaledToFillSizeFilter(size: viewCell.imageViewBlur.bounds.size)
                
                SwiftOverlays.showCenteredWaitOverlay(viewCell)
                
                self.downloader.download(urlRequest, filter: filter) { response in
                    
                    SwiftOverlays.removeAllOverlaysFromView(viewCell)
                    guard response.result.error == nil else {
                        
                        return
                    }
                    
                    viewCell.imageViewBlur.image =
                        response.result.value!.applyBlur(withRadius: 5,
                                                         tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4),
                                                         saturationDeltaFactor: 1,
                                                         maskImage: nil)
                    
                    viewCell.buttonAvatar.setImage(response.result.value!, for: .normal)
                    let layer = viewCell.buttonAvatar.layer
                    layer.borderColor = UIColor.white.cgColor
                    layer.borderWidth = 2
                }
            }
            else {
                
                let defaultImage = UIImage(named: "avatar")
                
                viewCell.imageViewBlur.image = defaultImage!.applyBlur(withRadius: 5,                                                                                                                                             tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4),                                                                                                                                                     saturationDeltaFactor: 1,                                                                                                                                                     maskImage: nil)
                
                viewCell.buttonAvatar.setImage(defaultImage, for: .normal)
                let layer = viewCell.buttonAvatar.layer
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 2
            }
        }
    }
    
    fileprivate func uploadImage(_ info:[String: AnyObject]) {
        
        let originalImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let rectValue = info["UIImagePickerControllerCropRect"] as? NSValue
        
        if let cropRect = rectValue?.cgRectValue {
            
            let croppedImage = originalImage.cgImage!.cropping(to: cropRect)
            
            if let cropped = croppedImage {
                
                let finalImage = UIImage(cgImage: cropped)
                
                if let superview = self.view.superview {
                    
                    SwiftOverlays.showCenteredWaitOverlay(superview)
                }
                
                Api.sharedInstance.uploadImage(image: finalImage)
                    
                    .onSuccess(callback: { uploadResponse in
                        
                        let imageUrlString = uploadResponse.url
                        print(imageUrlString)
                        
                        let realm = try! Realm()
                        if let user = realm.objects(User.self).first {
                            
                            Api.sharedInstance.applyUserImage(userId: user.id, imageId: uploadResponse.id)
                                
                                .onSuccess(callback: { user in
                                
                                    if let superview = self.view.superview {
                                        
                                        SwiftOverlays.removeAllOverlaysFromView(superview)
                                    }
                                    
                                    if self.userInfo.items.count > 0 {
                                        
                                        let indexPath = self.userInfo.items[0].indexPath!
                                        
                                        if let cell = self.tableView.cellForRow(at: indexPath) as? TUserProfileHeaderTableViewCell {
                                            
                                            cell.buttonAvatar.setImage(finalImage, for: .normal)
                                            cell.imageViewBlur.image = finalImage.applyBlur(withRadius: 5,
                                                                                            tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4),
                                                                                            saturationDeltaFactor: 1,
                                                                                            maskImage: nil)
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
}
