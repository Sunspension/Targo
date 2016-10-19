//
//  TFeedDetailsTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 18/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TFeedDetailsTableViewController: UITableViewController {

    fileprivate var dataSource = TableViewDataSource()
    
    var news: TFeedItem!
    
    var company: TCompany!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.tableView.setup()
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self.dataSource
        self.tableView.allowsSelection = false
        self.title = company.title
        
        createDataSource()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - Private methods
    
    fileprivate func createDataSource() {
        
        let section = CollectionSection()
        
        self.dataSource.sections.append(section)
        
        if company.alias == "targo" {
            
            section.initializeCellWithReusableIdentifierOrNibName("TagoNewsDetails",
                                                                  item: self.news,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let news = item.item as! TFeedItem
                                                                    let viewCell = cell as! TFeedTargoNewsDetailsTableViewCell
                                                                    
                                                                    viewCell.newsDetails.text = news.feedItemDescription
                                                                    
                                                                    let formatter = DateFormatter()
                                                                    formatter.dateFormat = kDateTimeFormat
                                                                    
                                                                    if let date = formatter.date(from: news.createdAt) {
                                                                        
                                                                        let formatter = DateFormatter()
                                                                        formatter.dateStyle = .short
                                                                        formatter.timeStyle = .short
                                                                        
                                                                        viewCell.date.text = formatter.string(from: date)
                                                                    }
            })
        }
        else {
            
            section.initializeCellWithReusableIdentifierOrNibName("CompanyNewsDetails",
                                                                  item: self.news,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let news = item.item as! TFeedItem
                                                                    let viewCell = cell as! TFeedCompanyNewsDetailsTableViewCell
                                                                    
                                                                    viewCell.companyTitle.text = self.company.title
                                                                    viewCell.newsDetails.text = news.feedItemDescription
                                                                    
                                                                    let formatter = DateFormatter()
                                                                    formatter.dateFormat = kDateTimeFormat
                                                                    
                                                                    if let date = formatter.date(from: news.createdAt) {
                                                                        
                                                                        let formatter = DateFormatter()
                                                                        formatter.dateStyle = .short
                                                                        formatter.timeStyle = .short
                                                                        
                                                                        viewCell.date.text = formatter.string(from: date)
                                                                    }
            })
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
