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
    
    case undefined
    
    case afterOrder
    
    case openOrderDetails
}


class TOrderStatusViewController: UIViewController {
    
    
    @IBOutlet weak var orderId: UILabel!
    
    @IBOutlet weak var companyUIImage: UIImageView!
    
    @IBOutlet weak var orderStatusDescription: UILabel!
    
    @IBOutlet weak var cancelOrder: UIButton!
    
    @IBOutlet weak var cancelLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    
    var shopOrder: TShopOrder?
    
    var companyName: String?
    
    var companyImage: TImage?
    
    var reason: OrderStatusOpenReasonEnum = .undefined
    
    var countDownTimer: CountdownTimer?
    
    let downloader = ImageDownloader()
    
    var previousOrderStatus: Int = 0
    
    
    deinit {
        
        print("\(String(describing: self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerLabel.textAlignment = .center
        
        self.cancelLabel.text = "order_cancel_order".localized
        self.cancelOrder.addTarget(self, action: #selector(TOrderStatusViewController.cancelOrderAction), for: .touchUpInside)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-bill"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.openBill))
        
        if self.reason == .afterOrder {
            
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "action_close".localized,
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(self.backAction))
        }
        
        if let order = self.shopOrder {
            
            self.orderId.text = "order_title".localized + " " + String(order.id)
            self.setOrderStatus(order)
        }
        
        self.title = companyName
        
        if let companyImage =  self.companyImage {
            
            let filter = AspectScaledToFillSizeFilter(size: self.companyUIImage.frame.size)
            
            let urlRequest = URLRequest(url: URL(string: companyImage.url)!)
            
            self.downloader.download(urlRequest, filter: filter) { response in
                
                guard response.result.value != nil else {
                    
                    return
                }
                
                self.companyUIImage.image =
                    response.result.value!.applyBlur(withRadius: 1,
                                                     tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4),
                                                     saturationDeltaFactor: 1,
                                                     maskImage: nil)
                DispatchQueue.main.async {
                    
                    self.companyUIImage.makeCircular()
                    self.companyUIImage.layer.borderColor = UIColor.white.cgColor
                    self.companyUIImage.layer.borderWidth = 5
                }
            }
        }
        
//        let transition = CATransition()
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionFade
//        transition.duration = 0.5
//        self.orderStatusDescription.layer.addAnimation(transition, forKey: "setStatus")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.checkOrderStatus()
    }
    
    func makeAttributedTimeString(time: String) -> NSAttributedString {
        
        let minutes = "minutes".localized
        let attrubuteTime = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 80)]
        
        let attrubuteMinutes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 30)]
        
        let text1 = NSAttributedString(string: time + "\n", attributes: attrubuteTime)
        let text2 = NSAttributedString(string: minutes, attributes: attrubuteMinutes)
        
        let attributedText = NSMutableAttributedString(attributedString: text1)
        attributedText.append(text2)
        
        return attributedText
    }
    
    func cancelOrderAction() {
        
        if let order = self.shopOrder
            , order.orderStatus != ShopOrderStatusEnum.canceledByUser.rawValue {
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
            
            Api.sharedInstance.cancelOrderByUser(orderId: order.id)
                
                .onSuccess(callback: {[weak self] order in
                    
                    self?.setOrderStatus(order)
                    
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoUserDidCancelOrderNotification), object: nil))
                    
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
        
        let _ = self.navigationController?.popToRootViewController(animated: true)
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
                , status != .canceled
                    && status != .finished
                    && status != .canceledByUser else {
                    
                    self.setOrderStatus(order)
                    return
            }
            
            Api.sharedInstance.checkShopOrderStatus(orderStatus: order.id)
                
                .onSuccess(callback: {[weak self] shopOrder in
                    
                    self?.shopOrder = shopOrder
                    self?.setOrderStatus(shopOrder)
                    
                    if shopOrder.orderStatus == ShopOrderStatusEnum.finished.rawValue {
                        
                        if let controller = self?.instantiateViewControllerWithIdentifierOrNibName("OrderFinished") as? TOrderFinishedViewController {
                            
                            controller.companyName = self?.companyName
                            controller.shopOrder = self?.shopOrder
                            
                            self?.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                    
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoDidLoadOrdersNotification), object: nil))
                    
                    if let status = ShopOrderStatusEnum(rawValue: shopOrder.orderStatus)
                        , status != .canceled && status != .finished {
                        
                        self?.perform(#selector(TOrderStatusViewController.checkOrderStatus),
                                      with: nil,
                            afterDelay: 5)
                    }
                    
                    }).onFailure(callback: { error in
                        
                        print(error.localizedDescription)
                    })
        }
    }
    
    fileprivate func enableTimerIfNeeded() {
        
        if let preparedTime = self.shopOrder?.prepared {
            
            let formatter = DateFormatter()
            formatter.dateFormat = kDateTimeFormat
            
            if let orderTime = formatter.date(from: preparedTime)?.timeIntervalSinceNow {
                
                if orderTime > 0 {
                    
                    countDownTimer = CountdownTimer(seconds: orderTime, callBack: {[weak self] time in
                        
                        if let time = time {
                            
                            self?.timerLabel.attributedText = self?.makeAttributedTimeString(time: time)
                        }
                        else {
                            
                            self?.timerLabel.attributedText = self?.makeAttributedTimeString(time: "0")
                        }
                    })
                    
                    countDownTimer?.startTimer()
                }
                else {
                    
                    self.timerLabel.attributedText = self.makeAttributedTimeString(time: "0")
                }
            }
            else {
                
                self.timerLabel.attributedText = self.makeAttributedTimeString(time: "0")
            }
        }
    }
    
    fileprivate func setOrderStatus(_ order: TShopOrder) {
        
        guard let status = ShopOrderStatusEnum(rawValue: order.orderStatus) else {
            
            changeStatusText(order.orderStatusTitle)
            self.cancelOrder.isHidden = true
            self.cancelLabel.isHidden = true
            return
        }
        
        self.changeStatusText(order.orderStatusTitle)
        
        switch status {
            
        // 1
        case .new:
            
            self.cancelOrder.isHidden = false
            self.cancelLabel.isHidden = false
            
            break
            
        // 2
        case .canceledByUser:
            
            self.cancelOrder.isHidden = true
            self.cancelLabel.isHidden = true
            
            break
            
        // 3
        case .view:
            
            self.cancelOrder.isHidden = false
            self.cancelLabel.isHidden = false
            
            break
            
        // 4
        case .canceled:
            
            self.cancelOrder.isHidden = true
            self.cancelLabel.isHidden = true
            
            break
            
        // 5
        case .paymentSuccess:
            
            if previousOrderStatus != ShopOrderStatusEnum.paymentSuccess.rawValue {
                
                self.previousOrderStatus = status.rawValue
                self.cancelOrder.isHidden = true
                self.cancelLabel.isHidden = true
            }
            
            break
            
        // 6
        case .complete:
            
            self.cancelOrder.isHidden = true
            self.cancelLabel.isHidden = true
            
            break
            
        // 7
        case .finished:
            
            self.cancelOrder.isHidden = true
            self.cancelLabel.isHidden = true
            
            break
            
        // 8
        case .payError:
            
            self.cancelOrder.isHidden = true
            self.cancelLabel.isHidden = true
            
            break
            
        // 9
        case .inProgress:
            
            self.cancelOrder.isHidden = true
            self.cancelLabel.isHidden = true
            self.enableTimerIfNeeded()
            
            break
            
        default:
            
            changeStatusText("")
            break
        }
    }
    
    fileprivate func changeStatusText(_ text: String) {
        
        UIView.transition(with: orderStatusDescription,
                                  duration: 0.3,
                                  options: [.transitionCrossDissolve],
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
