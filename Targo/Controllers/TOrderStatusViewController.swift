//
//  TOrderStatusViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftOverlays
import Bond

enum OrderStatusOpenReasonEnum {
    
    case Undefined
    
    case AfterOrder
    
    case OpenOrderDetails
}


class TOrderStatusViewController: UIViewController {
    
    
    @IBOutlet weak var orderId: UILabel!
    
    @IBOutlet weak var companyUIImage: UIImageView!
    
    @IBOutlet weak var statusIndicator1: UIView!
    
    @IBOutlet weak var statusIndicator2: UIView!
    
    @IBOutlet weak var statusIndicator3: UIView!
    
    @IBOutlet weak var statusIndicator4: UIView!
    
//    @IBOutlet weak var orderStatusImage: UIImageView!
    
    @IBOutlet weak var orderStatusDescription: UILabel!
    
    @IBOutlet weak var cancelOrder: UIButton!
    
    @IBOutlet weak var cancelLabel: UILabel!
    
    
    var shopOrder: TShopOrder?
    
    var companyName: String?
    
    var companyImage: TImage?
    
    var reason: OrderStatusOpenReasonEnum = .Undefined
    
    
    deinit {
        
        print("\(typeName(self)) \(#function)")
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        self.companyUIImage.makeCircular()
        self.companyUIImage.layer.borderColor = UIColor.whiteColor().CGColor
        self.companyUIImage.layer.borderWidth = 4
        
        self.statusIndicator1.makeCircular()
        self.statusIndicator2.makeCircular()
        self.statusIndicator3.makeCircular()
        self.statusIndicator4.makeCircular()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cancelLabel.text = "order_cancel_order".localized
        self.cancelOrder.addTarget(self, action: #selector(TOrderStatusViewController.cancelOrderAction), forControlEvents: .TouchUpInside)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-bill"),
                                                                 style: .Plain,
                                                                 target: self,
                                                                 action: #selector(TOrderStatusViewController.openBill))
        
        if self.reason == .AfterOrder {
            
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "action_close".localized,
                                                                    style: .Plain,
                                                                    target: self,
                                                                    action: #selector(TOrderStatusViewController.backAction))
        }
        
        if let order = self.shopOrder {
            
            self.orderId.text = "order_title".localized + " " + String(order.id)
            self.setOrderStatus(order.orderStatus)
        }
        
        self.title = companyName
        
        if let companyImage =  self.companyImage {
            
            let filter = AspectScaledToFillSizeFilter(size: self.companyUIImage.frame.size)
            self.companyUIImage.af_setImageWithURL(NSURL(string: companyImage.url)!, filter: filter)
        }
        
//        let transition = CATransition()
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionFade
//        transition.duration = 0.5
//        self.orderStatusDescription.layer.addAnimation(transition, forKey: "setStatus")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.checkOrderStatus()
    }
    
    func cancelOrderAction() {
        
        if let order = self.shopOrder
            where order.orderStatus != ShopOrderStatusEnum.CanceledByUser.rawValue {
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
            
            Api.sharedInstance.cancelOrderByUser(order.id)
                
                .onSuccess(callback: {[weak self] order in
                    
                    self?.setOrderStatus(order.orderStatus)
                    
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoUserDidCancelOrderNotification, object: nil))
                    
                    if let superview = self?.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    }).onFailure(callback: {[weak self] error in
                        
                        if let superview = self?.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        
                        print(error)
                    })
        }
    }
    
    func backAction() {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func openBill() {
        
//        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("OrderFinished") as? TOrderFinishedViewController {
//            
//            controller.companyName = self.companyName
//            controller.shopOrder = self.shopOrder
//            
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//        
//        return
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("OrderBill") as? TOrderBillTableViewController {
            
            controller.companyName = self.companyName
            controller.shopOrder = self.shopOrder
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func checkOrderStatus() {
        
        if let order = self.shopOrder {
            
            guard let status = ShopOrderStatusEnum(rawValue: order.orderStatus)
                where status != .Canceled
                    && status != .Finished
                    && status != .CanceledByUser else {
                    
                    self.setOrderStatus(order.orderStatus)
                    return
            }
            
            Api.sharedInstance.checkShopOrderStatus(order.id)
                
                .onSuccess(callback: {[weak self] shopOrder in
                    
                    self?.shopOrder = shopOrder
                    self?.setOrderStatus(shopOrder.orderStatus)
                    
                    if shopOrder.orderStatus == ShopOrderStatusEnum.Finished.rawValue {
                        
                        if let controller = self?.instantiateViewControllerWithIdentifierOrNibName("OrderFinished") as? TOrderFinishedViewController {
                            
                            controller.companyName = self?.companyName
                            controller.shopOrder = self?.shopOrder
                            
                            self?.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoDidLoadOrdersNotification, object: nil))
                    
                    if let status = ShopOrderStatusEnum(rawValue: shopOrder.orderStatus)
                        where status != .Canceled && status != .Finished {
                        
                        self?.performSelector(#selector(TOrderStatusViewController.checkOrderStatus),
                            withObject: nil,
                            afterDelay: 5)
                    }
                    
                    }).onFailure(callback: { error in
                        
                        print(error.localizedDescription)
                    })
        }
    }
    
    private func setOrderStatus(orderSatus: Int) {
        
        let status = ShopOrderStatusEnum(rawValue: orderSatus)!
        
        switch status {
            
            // 1
        case .New:
            
            changeStatusText("order_status_new".localized)
            statusIndicator1.backgroundColor = UIColor.lightGrayColor()
            statusIndicator2.backgroundColor = UIColor.lightGrayColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = false
            self.cancelLabel.hidden = false
            
            break
            
            // 2
        case .CanceledByUser:
            
//            orderStatusImage.image = UIImage(named: "icon-canceled")
            changeStatusText("order_status_canceled_by_user".localized)
//            orderStatusDescription.text = "order_status_canceled_by_user".localized
            statusIndicator1.backgroundColor = UIColor.lightGrayColor()
            statusIndicator2.backgroundColor = UIColor.lightGrayColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = true
            self.cancelLabel.hidden = true
            
            break
            
            // 3
        case .View:
            
//            orderStatusImage.image = UIImage(named: "icon-success")
            changeStatusText("order_status_seen".localized)
//            orderStatusDescription.text = "order_status_seen".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.lightGrayColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = false
            self.cancelLabel.hidden = false
            
            break

            // 4
        case .Canceled:
            
//            orderStatusImage.image = UIImage(named: "icon-canceled")
            
            changeStatusText("order_status_canceled".localized)
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.lightGrayColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = true
            self.cancelLabel.hidden = true
            
            break

            // 5
        case .Processing:
            
//            orderStatusImage.image = UIImage(named: "icon-clock")
            changeStatusText("order_status_processing".localized)
//            orderStatusDescription.text = "order_status_processing".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = true
            self.cancelLabel.hidden = true
            
            break
            
            // 6
        case .Complete:
            
//            orderStatusImage.image = UIImage(named: "icon-cutlery")
            changeStatusText("order_status_ready".localized)
//            orderStatusDescription.text = "order_status_ready".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.whiteColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = true
            self.cancelLabel.hidden = true
            
            break;
            
            // 7
        case .Finished:
            
//            orderStatusImage.image = UIImage(named: "icon-cutlery")
            changeStatusText("order_status_finished".localized)
//            orderStatusDescription.text = "order_status_finished".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.whiteColor()
            statusIndicator4.backgroundColor = UIColor.whiteColor()
            self.cancelOrder.hidden = true
            self.cancelLabel.hidden = true
            
            break
            
            // 8
        case .PaySuccess:
            
//            orderStatusImage.image = nil
            changeStatusText("order_status_pay_success".localized)
//            orderStatusDescription.text = "order_status_pay_success".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = true
            self.cancelLabel.hidden = true
            
            break
            
            // 9
        case .PayError:
            
//            orderStatusImage.image = nil
            changeStatusText("order_status_pay_error".localized)
//            orderStatusDescription.text = "order_status_pay_error".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            self.cancelOrder.hidden = true
            self.cancelLabel.hidden = true
            
            break
        }
    }
    
    private func changeStatusText(text: String) {
        
        UIView.transitionWithView(orderStatusDescription,
                                  duration: 0.3,
                                  options: [.TransitionCrossDissolve],
                                  animations: {
                                    
                                    self.orderStatusDescription.text = text
                                    
            }, completion: nil)
    }
    
//    private func showLocalNotification(text: String) {
//        
//        let notification = UILocalNotification()
//        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
//        notification.alertBody = text
//        notification.soundName = UILocalNotificationDefaultSoundName
//        notification.userInfo = ["CustomField1": "w00t"]
//        
//        UIApplication.sharedApplication().scheduleLocalNotification(notification)
//    }
}
