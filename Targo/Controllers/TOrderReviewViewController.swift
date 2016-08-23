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
    
    var deliverySelectedIndex = 0
    
    var selectedCardIndex = 0
    
    var company: TCompanyAddress?
    
    var companyImage: TCompanyImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "order_review_title".localized
        
        tableView.setup()
        tableView.dataSource = self.dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        
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
        button.hidden = true
        
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
        
        self.makeOrder.hidden = false
        
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
                
                self.selectedCardIndex = cards.count - 1
                
                section.initializeCellWithReusableIdentifierOrNibName("PaymentMethodCell",
                                                                      item: cards.last,
                                                                      itemType: 1,
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
            
            section.initializeCellWithReusableIdentifierOrNibName("DeliveryCell",
                                                                  item: nil,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TDeliveryMethodTableViewCell
                                                                    
                                                                    viewCell.deliveryMethod.tintColor = UIColor(hexString: kHexMainPinkColor)
                                                                    viewCell.selectionStyle = .None
                                                                    
                                                                    viewCell.deliveryMethod.bnd_selectedSegmentIndex.observe({ index in
                                                                        
                                                                        self.deliverySelectedIndex = index
                                                                    })
            })
        }
        
        dataSource.sections.append(section)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = self.dataSource.sections[indexPath.section].items[indexPath.row]
        
        guard item.itemType != nil else {
            
            return
        }
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("UserCreditCards")
            as? TUserCreditCardsTableViewController {
            
            controller.cards = self.cards
            controller.selectedAction = { cardIndex in
                
                self.selectedCardIndex = cardIndex
                
                let viewCell = tableView.cellForRowAtIndexPath(indexPath) as! TPaymentMethodTableViewCell
                let card = self.cards![cardIndex]
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
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func sendOrder(sender: AnyObject) {
        
        guard self.cards != nil && self.company != nil else {
            
            return
        }
        
        let card = self.cards![self.selectedCardIndex]
        var items: [Int : Int] = [:]
        
        for item in self.itemSource! {
            
            items[item.item.id] = item.count
        }
        
        let components = NSDateComponents()
        
        components.setValue(30, forComponent: .Minute)
        let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: NSDate(),
                                                                                 options: NSCalendarOptions(rawValue: 0))
        
        self.showWaitOverlay()
        
        Api.sharedInstance.makeShopOrder(card.id,
            items: items,
            addressId: 1, //self.company!.id
            serviceId: deliverySelectedIndex + 1,
            date: expirationDate!)
            
            .onSuccess {[weak self] shopOrder in
                
                self?.removeAllOverlays()
                
                if let controller = self?.instantiateViewControllerWithIdentifierOrNibName("OrderStatus") as? TOrderStatusViewController {
                    
                    controller.company = self?.company
                    controller.shopOrder = shopOrder
                    controller.companyImage = self?.companyImage
                    
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
                
                
                
            }.onFailure {[weak self] error in
                
                self?.removeAllOverlays()
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(action)
                self?.presentViewController(alert, animated: true, completion: nil)
                
        }
    }
}
