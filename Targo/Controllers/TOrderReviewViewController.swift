//
//  TBasketViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 14/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import SwiftOverlays

class TOrderReviewViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var makeOrder: UIButton!
    
    var itemSource: [(item: TShopGood, count: Int)]?
    
    var dataSource = TableViewDataSource()
    
    var cards: [TCreditCard]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "order_review_title".localized

        tableView.setup()
        tableView.dataSource = self.dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let button = self.makeOrder
        
        button.addTarget(self, action: #selector(TOrderReviewViewController.sendOrder),
                         forControlEvents: .TouchUpInside)
        button.setTitle("Make\norder", forState: .Normal)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 3
        
        let radius = button.layer.bounds.width / 2
        
        button.layer.cornerRadius = radius
        button.layer.shadowPath = UIBezierPath(roundedRect: button.layer.bounds, cornerRadius: radius).CGPath
        button.layer.shadowOffset = CGSize(width:0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        
        self.showWaitOverlay()
        
        Api.sharedInstance.loadCreditCards()
            .onSuccess { [weak self] cards in
                
                self?.removeAllOverlays()
                self?.cards = cards
                self?.createDataSource()
                self?.tableView.reloadData()
                
            }.onFailure { [weak self] error in
                
                self?.removeAllOverlays()
                print(error)
        }
    }
    
    private func createDataSource() {
        
        let section = CollectionSection()
        
        if let items = self.itemSource {
           
            var totalPrice = 0
            
            for item in items {
                
                totalPrice += item.count * item.item.price
                
                section.initializeCellWithReusableIdentifierOrNibName("OrderItemCell",
                                                                      item: item,
                                                                      bindingAction: { (cell, item) in
                                                                        
                                                                        let good = item.item as! (item: TShopGood, count: Int)
                                                                        let viewCell = cell as! TOrderItemTableViewCell
                                                                        
                                                                        viewCell.title.text = good.item.title
                                                                        viewCell.details.text = good.item.goodDescription
                                                                        viewCell.sum.text = String(good.count) + " x " + String(good.item.price) + " \u{20BD}"
                                                                        viewCell.selectionStyle = .None
                })
            }
            
            section.initializeCellWithReusableIdentifierOrNibName("OrderTotalPriceCell",
                                                                  item: totalPrice,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TOrderTotalPriceTableViewCell
                                                                    viewCell.details.text = "order_review_total_price".localized
                                                                    viewCell.price.text = String(item.item as! Int) + " \u{20BD}"
                                                                    viewCell.selectionStyle = .None
            })
            
            if let cards = self.cards where cards.count > 0 {
                
                section.initializeCellWithReusableIdentifierOrNibName("PaymentMethodCell",
                                                                      item: cards.last,
                                                                      bindingAction: { (cell, item) in
                                                                        
                                                                        let viewCell = cell as! TPaymentMethodTableViewCell
                                                                        let card = item.item as! TCreditCard
                                                                        
                                                                        viewCell.title.text = "credit_card_payment_method".localized
                                                                        viewCell.details.text = card.mask
                                                                        
                                                                        switch card.type {
                                                                            
                                                                        case "Visa":
                                                                            
                                                                            viewCell.icon.image = UIImage(named: "visa")
                                                                            
                                                                            break
                                                                            
                                                                        case "MasterCard":
                                                                            
                                                                            viewCell.icon.image = UIImage(named: "mastercard")
                                                                            
                                                                            break
                                                                            
                                                                        default:
                                                                            
                                                                            break
                                                                        }
                })
            }
        }
        
        dataSource.sections.append(section)
    }
    
    func sendOrder(sender: AnyObject) {
        
        
    }
}
