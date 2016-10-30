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
import ReactiveKit

private enum ItemTypeEnum : Int {
    
    case paymentMetod = 1
    
    case addNewCard
    
    case orderTime
 
    case numberOfPersons
    
    case deliveryType
    
    case orderDescription
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
    
    var companyImage: TImage?
    
    var loading = false
    
    var preparedDate: Date?
    
    var bag = DisposeBag()
    
    var keyboardListener: KeyboardNotificationListener?
    
    var orderDescription: String?
    
    
    deinit {
        
        print("\(typeName(self)) \(#function)")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "order_review_title".localized
        
        tableView.setup()
        tableView.dataSource = self.dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        
        tableView.register(UINib(nibName: "TDetailsTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "DetailsCell")
        
        tableView.register(UINib(nibName: "TOrderDescriptionTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "OrderDescriptionCell")
        
        tableView.register(UINib(nibName: "TOrderNumberOfPersons", bundle: nil),
                           forCellReuseIdentifier: "NumberOfPersonsCell")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TOrderReviewViewController.onDidAddCardNotification),
                                               name: NSNotification.Name(rawValue: kTargoDidAddNewCardNotification),
                                               object: nil)
        
        self.makeOrder.addTarget(self, action: #selector(TOrderReviewViewController.sendOrder),
                                 for: .touchUpInside)
        self.makeOrder.setTitle("order_make_order_button_title".localized, for: UIControlState())
        self.makeOrder.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        
        self.loadCards()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard text != "\n" else {
            
            textView.resignFirstResponder()
            self.orderDescription = textView.text
            return false
        }
        
        return true
    }
    
    func onDidAddCardNotification() {
        
        self.dataSource.sections.removeAll()
        self.loadCards()
    }
    
    func loadCards() {
        
        self.loading = true
        
        if let superView = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
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
    
    // MARK: - Private methods
    
    fileprivate func setStyleToOrderButton() {
        
        DispatchQueue.main.async { 
            
            let button = self.makeOrder
            
            button?.layer.borderColor = UIColor.white.cgColor
            button?.layer.borderWidth = 3
            button?.titleLabel?.textAlignment = .center
            button?.backgroundColor = UIColor(hexString: kHexMainPinkColor)
            
            let radius = (button?.layer.bounds.width)! / 2
            
            button?.layer.cornerRadius = radius
            button?.layer.shadowPath = UIBezierPath(roundedRect: (button?.layer.bounds)!, cornerRadius: radius).cgPath
            button?.layer.shadowOffset = CGSize(width:0, height: 1)
            button?.layer.shadowOpacity = 0.5
        }
    }
    
    fileprivate func createDataSource() {
        
        let section = CollectionSection()
        
        if let items = self.itemSource {
            
            var totalPrice = 0
            
            for item in items {
                
                totalPrice += item.count * item.item.price
                
                section.initializeCellWithReusableIdentifierOrNibName(identifier: "OrderItemCell",
                                                                      item: item,
                                                                      bindingAction: { (cell, item) in
                                                                        
                                                                        let good = item.item as! (item: TShopGood, count: Int)
                                                                        let viewCell = cell as! TOrderItemTableViewCell
                                                                        
                                                                        viewCell.title.text = good.item.title
                                                                        viewCell.details.text = good.item.goodDescription
                                                                        viewCell.sum.text = String(good.count) + " x " + String(good.item.price) + " \u{20BD}"
                                                                        viewCell.selectionStyle = .none
                })
            }
            
            section.initializeCellWithReusableIdentifierOrNibName(identifier: "OrderTotalPriceCell",
                                                                  item: totalPrice,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TOrderTotalPriceTableViewCell
                                                                    viewCell.details.text = "order_review_total_price".localized
                                                                    viewCell.price.text = String(item.item as! Int) + " \u{20BD}"
                                                                    viewCell.selectionStyle = .none
            })
            
            if let cards = self.cards , cards.count > 0 {
                
                self.selectedCardIndex = cards.count - 1
                
                section.initializeCellWithReusableIdentifierOrNibName(identifier: "PaymentMethodCell",
                                                                      item: cards.last,
                                                                      itemType: ItemTypeEnum.paymentMetod,
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
                
                section.initializeCellWithReusableIdentifierOrNibName(identifier: "PaymentMethodCell",
                                                                      item: nil,
                                                                      itemType: ItemTypeEnum.addNewCard,
                                                                      bindingAction: { (cell, item) in
                                                                        
                                                                        let viewCell = cell as! TPaymentMethodTableViewCell
                                                                        
                                                                        viewCell.title.text = "credit_card_payment_method".localized
                                                                        viewCell.details.text = "credit_card_add_new_one".localized
                                                                        viewCell.icon.image = UIImage(named: "icon-new-card")
                                                                        viewCell.icon.tintColor = UIColor(hexString: kHexMainPinkColor)
                })
            }
            
            section.initializeCellWithReusableIdentifierOrNibName(identifier: "DeliveryCell",
                                                                  item: nil,
                                                                  itemType: ItemTypeEnum.deliveryType,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TDeliveryMethodTableViewCell
                                                                    
                                                                    viewCell.deliveryMethod.tintColor = UIColor(hexString: kHexMainPinkColor)
                                                                    viewCell.selectionStyle = .none
                                                                    viewCell.deliveryMethod.setTitle("order_not_chosen".localized, forSegmentAt: 0)
                                                                    viewCell.deliveryMethod.setTitle("order_take_away".localized, forSegmentAt: 1)
                                                                    viewCell.deliveryMethod.setTitle("order_take_inside".localized, forSegmentAt: 2)
                                                                    
                                                                    let _ = viewCell.deliveryMethod
                                                                        .bnd_selectedSegmentIndex
                                                                        .observe(with: { (event: Event<Int, NoError>) in
                                                                        
                                                                        switch event {
                                                                            
                                                                        case .next(let index):
                                                                            
                                                                            self.serviceId = index
                                                                            break
                                                                            
                                                                            default:
                                                                            break
                                                                        }
                                                                    })
                })
            
            section.initializeCellWithReusableIdentifierOrNibName(identifier: "NumberOfPersonsCell",
                                                                  item: nil,
                                                                  itemType: ItemTypeEnum.numberOfPersons,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TOrderNumberOfPersons
                                                                    
                                                                    if item.userData == nil {
                                                                        
                                                                        item.userData = 1
                                                                    }
                                                                    
                                                                    viewCell.title.text = "order_number_of_persons_title".localized
                                                                    viewCell.quantityLabel.text = String(item.userData as! Int)
                                                                    
                                                                    viewCell.buttonPlus.bnd_tap.observe(with: {_ in 
                                                                        
                                                                        var count = item.userData as! Int
                                                                        count += 1
                                                                        item.userData = count
                                                                        viewCell.quantityLabel.text = String(count)
                                                                        
                                                                    }).disposeIn(viewCell.bag)
                                                                    
                                                                    viewCell.buttonMinus.bnd_tap.observe(with: {_ in 
                                                                        
                                                                        if let count = item.userData as? Int , count > 1 {
                                                                            
                                                                            var quantity = count
                                                                            quantity -= 1
                                                                            item.userData = quantity
                                                                            viewCell.quantityLabel.text = String(quantity)
                                                                        }
                                                                        
                                                                    }).disposeIn(viewCell.bag)

            })
            
            section.initializeCellWithReusableIdentifierOrNibName(identifier: "DetailsCell",
                                                                  item: nil,
                                                                  itemType: ItemTypeEnum.orderTime,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TDetailsTableViewCell
                                                                    
                                                                    viewCell.title.text = "order_time_title".localized
                                                                    viewCell.details.text = "order_time_place_holder".localized
            })
            
            section.initializeCellWithReusableIdentifierOrNibName(identifier: "OrderDescriptionCell",
                                                                  item: nil,
                                                                  itemType: ItemTypeEnum.orderDescription,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TOrderDescriptionTableViewCell
                                                                    
                                                                    viewCell.title.text = "order_description_title".localized
                                                                    let layer = viewCell.textView.layer
                                                                    layer.borderWidth = 1
                                                                    layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8).cgColor
                                                                    
                                                                    viewCell.textView.tintColor = UIColor(hexString: kHexMainPinkColor)
                                                                    viewCell.textView.isUserInteractionEnabled = false
                                                                    viewCell.textView.delegate = self
                })
            
        }
        
        dataSource.sections.append(section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.dataSource.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        guard item.itemType != nil else {
            
            return
        }
        
        let type = item.itemType as! ItemTypeEnum
        
        switch type {
            
        case .paymentMetod:
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("UserCreditCards")
                as? TUserCreditCardsTableViewController {
                
                controller.cards = self.cards
                controller.title = "credit_card_payment_method".localized
                controller.selectedAction = { cardIndex in
                    
                    self.selectedCardIndex = cardIndex
                    
                    let viewCell = tableView.cellForRow(at: indexPath) as! TPaymentMethodTableViewCell
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
            
        case .addNewCard:
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("AddCreditCard") {
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
            
        case .orderTime:
            
            let components = DateComponents()
            (components as NSDateComponents).setValue(1, forComponent: .hour)
            
            let expirationDate = (Calendar.current as NSCalendar).date(byAdding: components, to: Date(),
                                                                                     options: NSCalendar.Options(rawValue: 0))
            
            let viewCell = tableView.cellForRow(at: item.indexPath as IndexPath) as! TDetailsTableViewCell
            
            ActionSheetDatePicker.show(withTitle: "order_time_title".localized,
                                                      datePickerMode: .time,
                                                      selectedDate: self.preparedDate ?? expirationDate,
                                                      minimumDate: expirationDate,
                                                      maximumDate: expirationDate?.endOfDay,
                                                      doneBlock: {[weak self] (picker, selectedDate, view) in
                                                        
                                                        self?.preparedDate = selectedDate as? Date;
                                                        
                                                        if let date = selectedDate as? Date {
                                                            
                                                            viewCell.details.text = date.stringFromFormat("HH:mm")
                                                            viewCell.details.textColor = UIColor.black
                                                        }
                                                        
                }, cancel: { picker in
                    
                    
                }, origin: self.view.superview)
            
            break
            
            
            //        case .DeliveryType:
            //
            //            let alert = UIAlertController(title: "order_how_to_eat".localized, message: "", preferredStyle: .ActionSheet)
            //
            //            let takeAwayAction = UIAlertAction(title: "order_take_away".localized, style: .Default, handler: { action in
            //
            //                self.serviceId = 1
            //                let viewCell = tableView.cellForRowAtIndexPath(item.indexPath) as! TDetailsTableViewCell
            //                viewCell.details.text = "order_take_away".localized
            //                viewCell.details.textColor = UIColor.blackColor()
            //            })
            //
            //            let eatInsideAction = UIAlertAction(title: "order_take_inside".localized, style: .Default, handler: { action in
            //
            //                self.serviceId = 2
            //                let viewCell = tableView.cellForRowAtIndexPath(item.indexPath) as! TDetailsTableViewCell
            //                viewCell.details.text = "order_take_inside".localized
            //                viewCell.details.textColor = UIColor.blackColor()
            //            })
            //
            //            let cancel = UIAlertAction(title: "action_cancel".localized, style: .Cancel, handler: nil)
            //
            //            alert.addAction(takeAwayAction)
            //            alert.addAction(eatInsideAction)
            //            alert.addAction(cancel)
            //
            //            self.presentViewController(alert, animated: true, completion: nil)
            //
            //            break
            
        case .orderDescription:
            
            let cell = self.tableView.cellForRow(at: indexPath) as! TOrderDescriptionTableViewCell
            cell.textView.becomeFirstResponder()
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            
            break
            
        default:
            break
        }
    }
    
    func sendOrder(_ sender: AnyObject) {
        
        guard self.cards != nil && self.company != nil else {
            
            return
        }
        
        guard self.cards!.count > 0 else {
            
            self.showOkAlert("error".localized, message: "have_no_cards_alert_message".localized)
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
        
        let numberOfPersons = self.dataSource.sections.flatMap({ $0.items.filter({ $0.itemType as? ItemTypeEnum == ItemTypeEnum.numberOfPersons }) }).first
        
        Api.sharedInstance.makeShopOrder(cardId: card.id,
            items: items,
            addressId: self.company!.id,
            serviceId: self.serviceId,
            date: self.preparedDate,
            numberOfPersons: numberOfPersons?.userData as? Int,
            description: self.orderDescription)
            
            .onSuccess {[weak self] shopOrder in
                
                self?.removeAllOverlays()
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoDidLoadOrdersNotification), object: nil))
                
                if let controller = self?.instantiateViewControllerWithIdentifierOrNibName("OrderStatus") as? TOrderStatusViewController {
                    
                    controller.companyName = self?.company?.companyTitle
                    controller.shopOrder = shopOrder
                    controller.companyImage = self?.companyImage
                    controller.reason = .afterOrder
                    
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
                
            }.onFailure {[weak self] error in
                
                self?.removeAllOverlays()
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
                
        }
    }
}
