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

enum InfoSectionEnum {
    
    case CompanyImage
    case WorkingHours
    case AdditionalInfo
}

class TCompanyInfoTableViewController: UITableViewController {
    
    var company: TCompanyAddress?
    
    var companyImage: TCompanyImage?
    
    var itemsSource = TableViewDataSource()
    
    let workingHoursIdentifier = "workingHoursHeader"
    
    let companyContactsIdentifier = "companyContacts"
    
    let companyAboutIdentifier = "AboutCompanyCell"
    
    var makeOrderNavigationAction: (() -> Void)?
    
    var openMapNavigationAction:(()-> Void)?
    
    
    deinit {
        
        print("\(typeName(self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setup()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.itemsSource
        
        self.title = company?.companyTitle
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "icon-star"), style: .Plain, target: self, action: #selector(TCompanyInfoTableViewController.makeFavorite))
        
        rightButton.tintColor = UIColor.yellowColor()
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.tableView.registerNib(UINib(nibName: "TCompanyImageMenuTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "CompanyImageMenu")
        
        self.tableView.registerNib(UINib(nibName: "TWorkingHoursHeader", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: self.workingHoursIdentifier)
        
        self.tableView.registerNib(UINib(nibName: "TCompanyInfoContactsHeader", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: self.companyContactsIdentifier)
        
        self.createDataSource()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        switch section {
            
        case 1:
            
            let header = view as! TWorkingHoursHeader
            let button = header.buttonMakeOrder
            
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 3
            let radius = button.layer.bounds.width / 2
            button.layer.cornerRadius = radius
            button.layer.shadowPath = UIBezierPath(roundedRect: button.layer.bounds, cornerRadius: radius).CGPath
            button.layer.shadowOffset = CGSize(width:0, height: 1)
            button.layer.shadowOpacity = 0.5
            button.backgroundColor = UIColor(hexString: kHexMainPinkColor)
            
            break
            
        case 2:
            
            view.layer.shadowPath = UIBezierPath(rect: view.layer.bounds).CGPath
            view.layer.shadowOffset = CGSize(width: 0, height: 1)
            view.layer.shadowOpacity = 0.5
            
            break;
            
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
            
        case 1:
            
            if let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(self.workingHoursIdentifier) as? TWorkingHoursHeader {
                
                header.title.text = self.itemsSource.sections[section].title
                
                let button = header.buttonMakeOrder
                button.titleLabel?.textAlignment = .Center
                button.hidden = false
                button.addTarget(self, action: #selector(TCompanyInfoTableViewController.openCompanyMenu),
                                 forControlEvents: .TouchUpInside)
                button.setTitle("order_make_order_button_title".localized, forState: .Normal)
                
                return header
            }
            else {
                
                return nil
            }
            
        case 2:
            
            if let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(self.companyContactsIdentifier) as? TCompanyInfoContactsHeader {
                
                header.buttonPhone.setTitle(!self.company!.companyPhone.isEmpty ? self.company!.companyPhone : "+7 812 345 6789", forState: .Normal)
                header.buttonPhone.alignImageAndTitleVertically()
                header.buttonPhone.addTarget(self, action: #selector(TCompanyInfoTableViewController.makeCall), forControlEvents: .TouchUpInside)
                
                header.buttonLocation.setTitle(self.title, forState: .Normal)
                header.buttonLocation.alignImageAndTitleVertically()
                header.buttonLocation.addTarget(self, action: #selector(TCompanyInfoTableViewController.openMapAction), forControlEvents: .TouchUpInside)
                
                header.buttonLink.setTitle(!self.company!.companySite.isEmpty ? self.company!.companySite : "www.google.com", forState: .Normal)
                header.buttonLink.alignImageAndTitleVertically()
                header.buttonLink.addTarget(self, action: #selector(TCompanyInfoTableViewController.openURL), forControlEvents: .TouchUpInside)
                
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
            
        case 1:
            
            return 55
            
        case 2:
            
            return 80
            
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
            
            let phone = company.phone.isEmpty ? "79111111111" : company.phone
            
            do {
                
                let phoneNumber = try PhoneNumber(rawNumber: phone)
                
                let alertController = UIAlertController(title: "company_info_make_call_title".localized,
                                                        message: String(format:"company_info_make_call_confirmation".localized, phoneNumber.toInternational(true)),
                                                        preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "action_ok".localized, style: .Default, handler: { action in
                    
                    InterOperation.makeCall(phone)
                })
                
                let cancelAction = UIAlertAction(title: "action_cancel".localized, style: .Cancel, handler: nil)
                
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            catch {
                
                print("Parsing of phone number error")
            }
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
    
    func createDataSource() {
    
        let section = CollectionSection()
        section.sectionType = InfoSectionEnum.CompanyImage
        
        section.initializeCellWithReusableIdentifierOrNibName("CompanyImageMenu", item: self.companyImage) { (cell, item) in
            
            let viewCell = cell as! TCompanyImageMenuTableViewCell
            
            viewCell.layoutIfNeeded()
            
            viewCell.addBlurEffect()
            
            if let companyImage = item.item as? TCompanyImage {
                
                let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
                viewCell.companyImage.af_setImageWithURL(NSURL(string: companyImage.url)!, filter: filter)
            }
            
            viewCell.title.text = String(format: "company_info_opened_text".localized, "8:00 - 23:00")
            viewCell.selectionStyle = .None
        }
        
        self.itemsSource.sections.append(section)

        let workingHoursSection = CollectionSection(title: "company_info_working_hours".localized)
        
        let formatter = NSDateFormatter()
        
        for weekDay in 0...6 {
            
            let day = formatter.weekdaySymbols[weekDay]
            
            workingHoursSection.initializeCellWithReusableIdentifierOrNibName("WorkingHoursCell",
                                                                              item: day,
                                                                              bindingAction: { (cell, item) in
                                                                                
                                                                                let viewCell = cell as! TWorkingHoursTableViewCell
                                                                                viewCell.weekday.text = item.item as? String
                                                                                
                                                                                if let day = self.company?.backingWorkingTime[weekDay] {
                                                                                    
                                                                                    viewCell.hours.text = "\(day.begin) - \(day.end)"
                                                                                }
                                                                                
                                                                                viewCell.selectionStyle = .None
            })
        }
        
        self.itemsSource.sections.append(workingHoursSection)
        
        let aboutSection = CollectionSection()
        aboutSection.sectionType = InfoSectionEnum.AdditionalInfo
        
        aboutSection.initializeCellWithReusableIdentifierOrNibName(self.companyAboutIdentifier,
                                                                   item: self.company?.companyDescription) { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TCompanyAboutTableViewCell
                                                                    let text = item.item as! String
                                                                    
                                                                    viewCell.title.text = "company_info_about_us".localized
                                                                    viewCell.companyInfo.text = text
                                                                    viewCell.selectionStyle = .None
        }
        
        self.itemsSource.sections.append(aboutSection)
    }
    
    func openCompanyMenu() {
        
        self.makeOrderNavigationAction?()
    }
    
    func makeFavorite() {
        
        
    }
}
