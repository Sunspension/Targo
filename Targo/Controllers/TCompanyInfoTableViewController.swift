//
//  TCompanyInfoTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import AlamofireImage
import PhoneNumberKit
import SwiftOverlays

enum InfoSectionEnum {
    
    case companyImage
    case workingHours
    case additionalInfo
}

class TCompanyInfoTableViewController: UITableViewController {
    
    fileprivate let workingHoursIdentifier = "workingHoursHeader"
    
    fileprivate let companyContactsIdentifier = "companyContacts"
    
    fileprivate let companyAboutIdentifier = "AboutCompanyCell"
    
    fileprivate let bookmarkButton = UIButton(type: .custom)
    
    fileprivate var loadingStatus = TLoadingStatusEnum.idle
    
    var company: TCompanyAddress?
    
    var companyImage: TImage?
    
    var itemsSource = TableViewDataSource()
    
    var makeOrderNavigationAction: (() -> Void)?
    
    var openMapNavigationAction:(()-> Void)?
    
    
    deinit {
        
        print("\(typeName(self)) \(#function)")
    }
    
    class func controllerInstance() -> TCompanyInfoTableViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompanyInfoController") as! TCompanyInfoTableViewController
    }
    
    class func controllerInstance(addressId: Int) -> TCompanyInfoTableViewController {
        
        let controller = self.controllerInstance()
        controller.loadCompanyAddress(addressId: addressId)
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setup()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.itemsSource
        
        self.title = company?.companyTitle
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        bookmarkButton.setImage(UIImage(named: "icon-star"), for: UIControlState())
        bookmarkButton.setImage(UIImage(named: "icon-fullStar"), for: .selected)
        bookmarkButton.tintColor = UIColor.yellow
        bookmarkButton.addTarget(self, action: #selector(TCompanyInfoTableViewController.makeFavorite), for: .touchUpInside)
        bookmarkButton.sizeToFit()
        
        if let company = self.company {
            
            bookmarkButton.isSelected = company.isFavorite
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bookmarkButton)
        
        self.tableView.register(UINib(nibName: "TCompanyImageMenuTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "CompanyImageMenu")
        
        self.tableView.register(UINib(nibName: "TWorkingHoursHeader", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: self.workingHoursIdentifier)
        
        self.tableView.register(UINib(nibName: "TCompanyInfoContactsHeader", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: self.companyContactsIdentifier)
        
        self.createDataSource()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if self.loadingStatus != .loading {
            
            return
        }
        
        if let superview = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superview)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        switch section {
            
        case 1:
            
            let header = view as! TWorkingHoursHeader
            let button = header.buttonMakeOrder
            
            button?.layer.borderColor = UIColor.white.cgColor
            button?.layer.borderWidth = 3
            let radius = (button?.layer.bounds.width)! / 2
            button?.layer.cornerRadius = radius
            button?.layer.shadowPath = UIBezierPath(roundedRect: (button?.layer.bounds)!, cornerRadius: radius).cgPath
            button?.layer.shadowOffset = CGSize(width:0, height: 1)
            button?.layer.shadowOpacity = 0.5
            button?.backgroundColor = UIColor(hexString: kHexMainPinkColor)
            
            break
            
        case 2:
            
            view.layer.shadowPath = UIBezierPath(rect: view.layer.bounds).cgPath
            view.layer.shadowOffset = CGSize(width: 0, height: 1)
            view.layer.shadowOpacity = 0.5
            
            break;
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
            
        case 1:
            
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.workingHoursIdentifier) as? TWorkingHoursHeader {
                
                header.title.text = self.itemsSource.sections[section].title
                
                let button = header.buttonMakeOrder
                button?.titleLabel?.textAlignment = .center
                button?.isHidden = false
                button?.addTarget(self, action: #selector(TCompanyInfoTableViewController.openCompanyMenu),
                                 for: .touchUpInside)
                button?.setTitle("order_make_order_button_title_new_line".localized, for: UIControlState())
                
                return header
            }
            else {
                
                return nil
            }
            
        case 2:
            
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.companyContactsIdentifier) as? TCompanyInfoContactsHeader {
                
//                header.buttonPhone.setTitle(self.company!.companyPhone, for: UIControlState())
//                header.buttonPhone.alignImageAndTitleVertically()
                header.buttonPhone.addTarget(self, action: #selector(TCompanyInfoTableViewController.makeCall), for: .touchUpInside)
                
//                header.buttonLocation.setTitle(self.company?.title, for: UIControlState())
//                header.buttonLocation.alignImageAndTitleVertically()
                header.buttonLocation.addTarget(self, action: #selector(TCompanyInfoTableViewController.openMapAction), for: .touchUpInside)
                
//                header.buttonLink.setTitle(!self.company!.companySite.isEmpty ? self.company!.companySite : "www.google.com", for: UIControlState())
//                header.buttonLink.alignImageAndTitleVertically()
                header.buttonLink.addTarget(self, action: #selector(TCompanyInfoTableViewController.openURL), for: .touchUpInside)
                header.background.backgroundColor = UIColor(hexString: kHexMainPinkColor)
                return header
            }
            else {
                
                return nil
            }
            
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
            
        case 1:
            
            return 55
            
        case 2:
            
            return 60
            
        default:
             return 0.01
        }
    }
    
    func openURL() {
        
        if let company = self.company {
            
            let urlString = company.companySite.isEmpty ? "http://www.google.com" : company.companySite
            InterOperation.openBrowser(urlString)
        }
    }
    
    func openMapAction() {
        
        self.openMapNavigationAction?()
    }
    
    func makeCall() {
        
        if let company = self.company {
            
            let alertController = UIAlertController(title: "company_info_make_call_title".localized,
                                                    message: String(format:"company_info_make_call_confirmation".localized, company.phone),
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "action_ok".localized, style: .default, handler: { action in
                
                InterOperation.makeCall(company.phone)
            })
            
            let cancelAction = UIAlertAction(title: "action_cancel".localized, style: .cancel, handler: nil)
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
    
    func openCompanyMenu() {
        
        self.makeOrderNavigationAction?()
    }

    func makeFavorite() {
        
        self.bookmarkButton.isSelected = !self.bookmarkButton.isSelected
        
        if self.bookmarkButton.isSelected {
            
            Api.sharedInstance.addBookmark(companyAddressId: self.company!.id)
                
                .onFailure { error in
                    
                    self.bookmarkButton.isSelected = !self.bookmarkButton.isSelected
            }
        }
        else {
            
            Api.sharedInstance.removeBookmark(companyAddressId: self.company!.id)
                
                .onFailure { error in
                    
                    self.bookmarkButton.isSelected = !self.bookmarkButton.isSelected
            }
        }
    }
    
    //MARK: - Private methods
    
    fileprivate func loadCompanyAddress(addressId: Int) {
        
        self.loadingStatus = .loading
        
        Api.sharedInstance.loadCompanyAddress(addressId: addressId)
            
            .onSuccess { [unowned self] company in
                
                self.company = company
                self.title = company.companyTitle
                self.bookmarkButton.isSelected = company.isFavorite
                
                Api.sharedInstance.loadImage(imageId: company.companyImageId.value!)
                    
                    .onSuccess(callback: { [unowned self] image in
                        
                        self.loadingStatus = .loaded
                        self.companyImage = image
                        self.createDataSource()
                        self.tableView.reloadData()
                    })
                    .onFailure(callback: { [unowned self] error in
                        
                        self.loadingStatus = .failed
                        
                        if let superview = self.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                    })
            }
            .onFailure(callback: { [unowned self] error in
                
                self.loadingStatus = .failed
                
                if let superview = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
            })
    }
    
    fileprivate func createDataSource() {
    
        guard self.company != nil else {
            
            return
        }
        
        let section = CollectionSection()
        section.sectionType = InfoSectionEnum.companyImage
        
        section.initializeItem(reusableIdentifierOrNibName: "CompanyImageMenu",
                               item: self.companyImage) { (cell, item) in
            
            let viewCell = cell as! TCompanyImageMenuTableViewCell
            
            viewCell.layoutIfNeeded()
            
            viewCell.addBlurEffect()
            
            if let companyImage = item.item as? TImage {
                
                let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
                viewCell.companyImage.af_setImage(withURL: URL(string: companyImage.url)!, filter: filter)
            }
            
            if let workingHours = self.company!.todayWorkingHours {
                
                if workingHours.count == 2 {
                    
                    viewCell.title.text = String(format: "company_info_opened_text".localized, "\(workingHours[0]) - \(workingHours[1])")
                }
            }
            
            viewCell.point.backgroundColor = UIColor.green
            
            viewCell.selectionStyle = .none
        }
        
        self.itemsSource.sections.append(section)

        let workingHoursSection = CollectionSection(title: "company_info_working_hours".localized)
        
        let calendar = Calendar.current
        
        for index in 0...6 {
            
            let weekDay = (index + 1) % 7
            
            let day = calendar.weekdaySymbols[weekDay]
            
            workingHoursSection.initializeItem(reusableIdentifierOrNibName: "WorkingHoursCell",
                                               item: day,
                                               bindingAction: { (cell, item) in
                                                
                                                let viewCell = cell as! TWorkingHoursTableViewCell
                                                viewCell.weekday.text = item.item as? String
                                                
                                                if let day = self.company?.backingWorkingTime[index] {
                                                    
                                                    viewCell.hours.text = "\(day.begin) - \(day.end)"
                                                }
                                                
                                                viewCell.selectionStyle = .none
            })
        }
        
        self.itemsSource.sections.append(workingHoursSection)
        
        let aboutSection = CollectionSection()
        aboutSection.sectionType = InfoSectionEnum.additionalInfo
        
        aboutSection.initializeItem(reusableIdentifierOrNibName: self.companyAboutIdentifier,
                                    item: self.company?.companyDescription) { (cell, item) in
                                        
                                        let viewCell = cell as! TCompanyAboutTableViewCell
                                        let text = item.item as! String
                                        
                                        viewCell.title.text = "company_info_about_us".localized
                                        viewCell.companyInfo.text = text
                                        viewCell.selectionStyle = .none
        }
        
        self.itemsSource.sections.append(aboutSection)
    }
}
