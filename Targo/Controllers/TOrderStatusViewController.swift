//
//  TOrderStatusViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import AlamofireImage

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
    
    @IBOutlet weak var orderStatusImage: UIImageView!
    
    @IBOutlet weak var orderStatusDescription: UILabel!
    
    @IBOutlet weak var cancelOrder: CenteredButton!
    
    var shopOrder: TShopOrder?
    
    var companyName: String?
    
    var companyImage: TCompanyImage?
    
    var reason: OrderStatusOpenReasonEnum = .Undefined
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.statusIndicator1.makeCircular()
        self.statusIndicator2.makeCircular()
        self.statusIndicator3.makeCircular()
        self.statusIndicator4.makeCircular()
        
        self.companyUIImage.makeCircular()
        self.companyUIImage.layer.borderColor = UIColor.whiteColor().CGColor
        self.companyUIImage.layer.borderWidth = 4
        
        self.cancelOrder.setTitle("order_cancel_order".localized, forState: .Normal)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-bill"), style: .Plain, target: self, action: #selector(TOrderStatusViewController.openBill))
        
        if self.reason == .AfterOrder {
            
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "action_close".localized, style: .Plain, target: self, action: #selector(TOrderStatusViewController.backAction))
        }
        
        if let order = self.shopOrder {
            
            self.orderId.text = "order_title".localized + " " + String(order.id)
            self.setOrderStatus(order.orderStatus)
        }
        
        self.title = companyName
        
        if let companyImage =  self.companyImage {
            
            let filter = AspectScaledToFillSizeFilter(size: self.companyUIImage.frame.size)
            self.companyUIImage.af_setImageWithURL(NSURL(string: companyImage.url)!,
                                                   filter: filter,
                                                   imageTransition: .None)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.checkOrderStatus()
    }
    
    func backAction() {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func openBill() {
        
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
                    && status != .Completed else {
                    
                    self.setOrderStatus(order.orderStatus)
                    return
            }
            
            Api.sharedInstance.checkShopOrderStatus(order.id)
                
                .onSuccess(callback: {[weak self] shopOrder in
                    
                    self?.shopOrder = shopOrder
                    self?.setOrderStatus(shopOrder.orderStatus)
                    
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
            
        case .New:
            
            orderStatusDescription.text = "order_status_new".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.lightGrayColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()

            
            break
            
        case .View:
            
            orderStatusImage.image = UIImage(named: "icon-success")
            orderStatusDescription.text = "order_status_seen".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            
            break
            
        case .Processing:
            
            orderStatusImage.image = UIImage(named: "icon-clock")
            orderStatusDescription.text = "order_status_processing".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.whiteColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
            
            break
            
        case .Canceled:
            
            orderStatusImage.image = UIImage(named: "icon-canceled")
            orderStatusDescription.text = "order_status_canceled".localized
            statusIndicator1.backgroundColor = UIColor.lightGrayColor()
            statusIndicator2.backgroundColor = UIColor.lightGrayColor()
            statusIndicator3.backgroundColor = UIColor.lightGrayColor()
            statusIndicator4.backgroundColor = UIColor.lightGrayColor()
                
            break
            
        case .Completed:
            
            orderStatusImage.image = UIImage(named: "icon-cutlery")
            orderStatusDescription.text = "order_status_ready".localized
            statusIndicator1.backgroundColor = UIColor.whiteColor()
            statusIndicator2.backgroundColor = UIColor.whiteColor()
            statusIndicator3.backgroundColor = UIColor.whiteColor()
            statusIndicator4.backgroundColor = UIColor.whiteColor()
            
            break;
            
        default:
            break
        }
    }
}
