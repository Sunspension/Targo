//
//  TCompanyMenuTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor

class TCompanyMenuTableViewController: UITableViewController {

    var company: TCompany?
    
    var companyImage: UIImage?
    
    var itemsSource = TableViewDataSource()
    
    var menuPage: TCompanyMenuPage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = company?.companyTitle
        
        self.tableView.setup()
        self.tableView.delegate = self
        self.tableView.dataSource = self.itemsSource
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"), style: .Plain, target: self, action: #selector(TCompanyMenuTableViewController.openInfo))
        
        self.tableView.registerNib(UINib(nibName: "TCompanyImageMenuTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "CompanyImageMenu")
        
        self.tableView.registerNib(UINib(nibName: "TCompanyMenuHeaderView", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: "sectionHeader")
    
        if let company = company {
            
            Api.sharedInstance.loadCompanyMenu(1).onSuccess(callback: { menuPage in
                
                self.menuPage = menuPage
                self.createDataSource()
                self.tableView.reloadData()
            })
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setup()
    }
    
    func openInfo() {
        
        
    }
    
    func createDataSource() {
        
        let section = CollectionSection()
        
        section.initializeCellWithReusableIdentifierOrNibName("CompanyImageMenu", item: self.companyImage) { (cell, item) in
            
            let viewCell = cell as! TCompanyImageMenuTableViewCell
            viewCell.companyImage.image = item?.item as? UIImage
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("WorkingTimeViewCell", item: company) { (cell, item) in
        }
        
        self.itemsSource.sections.append(section)
        
        for good in self.menuPage!.goods {
            
            var section = self.itemsSource.sections.filter({ $0.sectionType as? Int == good.shopCategoryId }).first
            
            if (section == nil) {
                
                let category = menuPage!.categories.filter({ $0.id == good.shopCategoryId }).first
                section = CollectionSection(title: category!.title)
                section?.sectionType = good.shopCategoryId
                self.itemsSource.sections.append(section!)
            }
            
            section!.initializeDefaultCell("default",
                                           cellStyle: .Subtitle,
                                           item: good,
                                           bindingAction: { (cell, item) in
                                            
                                            let itemGood = item!.item as! TShopGood
                                            
                                            cell.textLabel?.text = itemGood.title
                                            cell.detailTextLabel?.text = itemGood.goodDescription
            })
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return section == 0 ? nil : tableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader")
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 0 {
            
            return
        }
        
        let header = view as! TCompanyMenuHeaderView
        
        if header.layer.shadowPath != nil {
            
            return
        }
        
        header.background.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        header.layer.shadowPath = UIBezierPath(rect: header.layer.bounds).CGPath
        header.layer.shadowOffset = CGSize(width: 0, height: 2)
        header.layer.shadowOpacity = 0.5
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.01 : 30
    }
    
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

}
