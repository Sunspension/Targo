//
//  TBasketViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 14/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import SwiftOverlays
import ActionSheetPicker_3_0
import Timepiece
import Bond

private enum ItemTypeEnum : Int {
    
    case PaymentMetod = 1
    
    case AddNewCard
    
    case OrderTime
    
    case DeliveryType
    
    case OrderDescription
}


class TOrderReviewViewController: UIViewController, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var makeOrder: UIButton!
    
    var itemSource: [(item: TShopGood, count: Int)]?
    
    var dataSource = TableViewDataSource()
    
    var cards: [TCreditCard]?
    
    var serviceId = 0
    
    var selectedCardIndex = 0
    
    var company: TCompanyAddress?
    
    var companyImage: TCompanyImage?
    
    var loading = false
    
    var preparedDate: NSDate?
    
    var bag = DisposeBag()
    
    var keyboardListener: KeyboardNotificationListener?
    
    var orderDescription: String?
    
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        let button = self.makeOrder
        
        button.addTarget(self, action: #selector(TOrderReviewViewController.sendOrder),
                         forControlEvents: .TouchUpInside)
        button.setTitle("order_make_order_button_title".localized, forState: .Normal)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 3
        
        let radius = button.layer.bounds.width / 2
        
        button.layer.cornerRadius = radius
        button.layer.shadowPath = UIBezierPath(roundedRect: button.layer.bounds, cornerRadius: radius).CGPath
        button.layer.shadowOffset = CGSize(width:0, height: 1)
        button.layer.shadowOpacity = 0.5
        button.backgroundColor = UIColor(hexString: kHexMainPinkColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "order_review_title".localized
        
        tableView.setup()
        tableView.dataSource = self.dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        
        tableView.registerNib(UINib(nibName: "TDetailsTableViewCell", bundle: nil),
                              forCellReuseIdentifier: "DetailsCell")
        
        tableView.registerNib(UINib(nibName: "TOrderDescriptionTableViewCell", bundle: nil),
                              forCellReuseIdentifier: "OrderDescriptionCell")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .Plain,
                                                                target: nil,
                                                                action: nil)
        
        self.makeOrder.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(TOrderReviewViewController.onDidAddCardNotification),
                                                         name: kTargoDidAddNewCardNotification,
                                                         object: nil)
        
        self.loadCards()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.keyboardListener = KeyboardNotificationListener(tableView: self.tableView)
        
        if !self.loading {
            
            return
        }
        
        if let superView = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
    }
    
    //MARK: - UITextView delegate implementation
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        guard text != "\n" else {
            
            textView.resignFirstResponder()
            self.orderDescription = textView.text
            return false
        }
        
        return true
    }
    
    func onDidAddCardNotification() {
        
        if let superView = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
        self.dataSource.sections.removeAll()
        self.loadCards()
    }
    
    func loadCards() {
        
        self.loading = true
        
        Api.sharedInstance.loadCreditCards()
            .onSuccess { [weak self] cards in
                
                self?.loading = false
                
                if let superView = self?.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                self?.cards = cards
                self?.createDataSource()
                self?.tableView.reloadData()
                
            }.onFailure { [weak self] error in
                
                self?.loading = false
                
                if let superView = self?.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
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
                                                                      itemType: ItemTypeEnum.PaymentMetod,
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
            else {
                
                section.initializeCellWithReusableIdentifierOrNibName("PaymentMethodCell",
                                                                      item: nil,
                                                                      itemType: ItemTypeEnum.AddNewCard,
                                                                      bindingAction: { (cell, item) in
                                                                        
                                                                        let viewCell = cell as! TPaymentMethodTableViewCell
                                                                        
                                                                        viewCell.title.text = "credit_card_payment_method".localized
                                                                        viewCell.details.text = "credit_card_add_new_one".localized
                                                                        viewCell.icon.image = UIImage(named: "icon-new-card")
                                                                        viewCell.icon.tintColor = UIColor(hexString: kHexMainPinkColor)
                })
            }
            
            section.initializeCellWithReusableIdentifierOrNibName("DetailsCell",
                                                                  item: nil,
                                                                  itemType: ItemTypeEnum.OrderTime,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TDetailsTableViewCell
                                                                    
                                                                    viewCell.title.text = "order_time_title".localized
                                                                    viewCell.details.text = "order_time_place_holder".localized
            })
            
            section.initializeCellWithReusableIdentifierOrNibName("DetailsCell",
                                                                  item: nil,
                                                                  itemType: ItemTypeEnum.DeliveryType,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TDetailsTableViewCell
                                                                    
                                                                    viewCell.title.text = "order_how_to_eat".localized
                                                                    viewCell.details.text = "order_how_to_eat_place_holder".localized
            })
            
//            section.initializeCellWithReusableIdentifierOrNibName("DeliveryCell",
//                                                                  item: nil,
//                                                                  bindingAction: {[unowned self] (cell, item) in
//                                                                    
//                                                                    let viewCell = cell as! TDeliveryMethodTableViewCell
//                                                                    
//                                                                    viewCell.deliveryMethod.tintColor = UIColor(hexString: kHexMainPinkColor)
//                                                                    viewCell.selectionStyle = .None
//                                                                    
//                                                                    viewCell.deliveryMethod.bnd_selectedSegmentIndex.observe({ index in
//                                                                        
//                                                                        self.deliverySelectedIndex = index
//                                                                    })
//            })
            
            section.initializeCellWithReusableIdentifierOrNibName("OrderDescriptionCell",
                                                                  item: nil,
                                                                  itemType: ItemTypeEnum.OrderDescription,
                                                                  bindingAction: {[unowned self] (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TOrderDescriptionTableViewCell
                                                                    
                                                                    viewCell.title.text = "order_description_title".localized
                                                                    let layer = viewCell.textView.layer
                                                                    layer.borderWidth = 1
                                                                    layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8).CGColor
                                                                    
                                                                    viewCell.textView.tintColor = UIColor(hexString: kHexMainPinkColor)
                                                                    viewCell.textView.userInteractionEnabled = false
                                                                    viewCell.textView.delegate = self
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
        
        let type = item.itemType as! ItemTypeEnum
        
        switch type {
            
        case .PaymentMetod:
            
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
            
            break
            
        case .AddNewCard:
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("AddCreditCard") {
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
            
        case .OrderTime:
            
            let components = NSDateComponents()
            components.setValue(1, forComponent: .Hour)
            
            let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: NSDate(),
                                                                                     options: NSCalendarOptions(rawValue: 0))
            
            let viewCell = tableView.cellForRowAtIndexPath(item.indexPath) as! TDetailsTableViewCell
            
            ActionSheetDatePicker.showPickerWithTitle("order_time_title".localized,
                                                      datePickerMode: .Time,
                                                      selectedDate: self.preparedDate ?? expirationDate,
                                                      minimumDate: expirationDate,
                                                      maximumDate: expirationDate?.endOfDay,
                                                      doneBlock: {[weak self] (picker, selectedDate, view) in
                                                        
                                                        self?.preparedDate = selectedDate as? NSDate;
                                                        
                                                        if let date = selectedDate {
                                                            
                                                            viewCell.details.text = date.stringFromFormat("HH:mm")
                                                            viewCell.details.textColor = UIColor.blackColor()
                                                        }
                                                        
                }, cancelBlock: { picker in
                    
                    
                }, origin: self.view.superview)
            
            break
            
            
        case .DeliveryType:
            
            let alert = UIAlertController(title: "order_how_to_eat".localized, message: "", preferredStyle: .ActionSheet)
            
            let takeAwayAction = UIAlertAction(title: "order_take_away".localized, style: .Default, handler: { action in
                
                self.serviceId = 1
                let viewCell = tableView.cellForRowAtIndexPath(item.indexPath) as! TDetailsTableViewCell
                viewCell.details.text = "order_take_away".localized
                viewCell.details.textColor = UIColor.blackColor()
            })
            
            let eatInsideAction = UIAlertAction(title: "order_take_inside".localized, style: .Default, handler: { action in
                
                self.serviceId = 2
                let viewCell = tableView.cellForRowAtIndexPath(item.indexPath) as! TDetailsTableViewCell
                viewCell.details.text = "order_take_inside".localized
                viewCell.details.textColor = UIColor.blackColor()
            })
            
            let cancel = UIAlertAction(title: "action_cancel".localized, style: .Cancel, handler: nil)
            
            alert.addAction(takeAwayAction)
            alert.addAction(eatInsideAction)
            alert.addAction(cancel)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            break
            
        case .OrderDescription:
            
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TOrderDescriptionTableViewCell
            cell.textView.becomeFirstResponder()
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
            
            break
        }
    }
    
    func sendOrder(sender: AnyObject) {
        
        guard self.cards != nil && self.company != nil else {
            
            return
        }
        
        guard self.cards!.count > 0 else {
            
            self.showOkAlert("error".localized, message: "have_no_cards_alert_message".localized)
            return
        }
        
        guard self.preparedDate != nil else {
            
            self.showOkAlert("error".localized, message: "oder_time_to_prepare_empty".localized)
            return
        }
        
        guard self.serviceId != 0 else {
            
            self.showOkAlert("error".localized, message: "oder_delivery_service_empty".localized)
            return
        }
        
        let card = self.cards![self.selectedCardIndex]
        var items: [Int : Int] = [:]
        
        for item in self.itemSource! {
            
            items[item.item.id] = item.count
        }
        
        self.showWaitOverlay()
        
        Api.sharedInstance.makeShopOrder(card.id,
            items: items,
            addressId: self.company!.id,
            serviceId: serviceId,
            date: self.preparedDate!,
            description: self.orderDescription)
            
            .onSuccess {[weak self] shopOrder in
                
                self?.removeAllOverlays()
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoDidLoadOrdersNotification, object: nil))
                
                if let controller = self?.instantiateViewControllerWithIdentifierOrNibName("OrderStatus") as? TOrderStatusViewController {
                    
                    controller.companyName = self?.company?.companyTitle
                    controller.shopOrder = shopOrder
                    controller.companyImage = self?.companyImage
                    controller.reason = .AfterOrder
                    
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
