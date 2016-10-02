//
//  TCompaniesOnMapsViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 23/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import GoogleMaps
import AlamofireImage
import Bond
import SwiftOverlays
import BrightFutures

enum OpenMapsReasonEnum {
    
    case AllCompanies
    
    case OneCompany
}


class TCompaniesOnMapsViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet weak var companyView: UIView!
    
    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var companyAddress: UILabel!
    
    @IBOutlet weak var companyInfo: UILabel!
    
    @IBOutlet weak var companyImage: UIImageView!

    
    private var userLocation: CLLocation?
    
    private var loadingStatus = TLoadingStatusEnum.Idle
    
    private var mapsMarkers = Array<GMSMarker>()
    
    var images: [TCompanyImage]?
    
    var selectedMarker: GMSMarker?
    
    var didsetLocation = false
    
    var companies: [TCompanyAddress]?
    
    var reason = OpenMapsReasonEnum.AllCompanies
    
    var failedtimer: NSTimer?
    

    deinit {
        
        print("\(typeName(self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
        
        self.title = "maps_title".localized
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.mapView.bringSubviewToFront(self.companyView)
        self.companyView.alpha = 0
        
        TLocationManager.sharedInstance.subscribeObjectForLocationChange(self,
                                                                         selector: #selector(TCompaniesOnMapsViewController.userLocationChanged))
        
        if self.reason == .OneCompany {
            
            self.addMarkers()
        }
        else {

            self.mapView.alpha = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.failedtimer?.invalidate()
        removeAllOverlays()
    }
    
    func startFailedTimer() {
        
        self.failedtimer = NSTimer.scheduledTimerWithTimeInterval(15,
                                                                  target: self,
                                                                  selector: #selector(TCompaniesOnMapsViewController.onFailedLoadCompaniesTimerEvent),
                                                                  userInfo: nil,
                                                                  repeats: false)
    }
    
    func onFailedLoadCompaniesTimerEvent() {
        
        self.failedtimer?.invalidate()
        
        if self.loadingStatus == .Loading {
            
            return
        }
        
        self.loadCompanies()
    }
    
    func loadCompanies() -> Future<TCompanyAddressesPage, TargoError> {
        
        if self.userLocation == nil {
            
            self.loadingStatus = .Failed
            
            self.startFailedTimer()
        }
        
        self.loadingStatus = .Loading
        
        showWaitOverlay()
        
        return Api.sharedInstance.loadCompanyAddresses(
            self.userLocation!,
            pageNumber: 1,
            pageSize: 1000,
            query: nil,
            distance: 50000)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                if let superview = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
                self.loadingStatus = .Loaded
                
                self.images = companyPage.images
                self.companies = companyPage.companies
                
                self.addMarkers()
                
                }).onFailure(callback: { [unowned self] error in
                    
                    self.loadingStatus = .Failed
                    
                    self.startFailedTimer()
                    self.removeAllOverlays()
                    
                    print(error)
                })
    }
    
    func addMarkers() {
        
        if let companies = self.companies {
            
            for marker in self.mapsMarkers {
                
                marker.map = nil
            }
            
            self.mapsMarkers.removeAll()
            
            for company in companies {
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
                marker.title = company.companyTitle
                marker.snippet = company.companyDescription
                marker.userData = company
                marker.map = self.mapView
                marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
                marker.appearAnimation = kGMSMarkerAnimationPop
                
                self.mapsMarkers.append(marker)
                
                if reason == .OneCompany {
                    
                    self.displayCompanyInfo(marker)
                    self.mapView.camera = GMSCameraPosition.cameraWithTarget(marker.position, zoom: 13)
                }
            }
        }
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        self.selectedMarker?.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        
        self.displayCompanyInfo(marker)
        
        return true
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        self.companyView.alpha = 0
        self.selectedMarker?.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        self.selectedMarker = nil
    }
    
    func userLocationChanged() {
        
        self.userLocation = TLocationManager.sharedInstance.lastLocation
        self.loadCompanies()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let newValue = change {
            
            if let location: CLLocation = newValue[NSKeyValueChangeNewKey] as? CLLocation {
                
                if self.reason == .AllCompanies && self.loadingStatus != .Loading {
                    
                    self.userLocation = location
                    
                    self.loadCompanies().andThen(callback: { _ in
                        
                        self.mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 13)
                        
                        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                            
                            self.mapView.alpha = 1
                            
                            }, completion: nil)
                    })
                }
                else {
                    
                    self.addMarkers()
                }
                
                self.mapView.removeObserver(self, forKeyPath: "myLocation")
            }
        }
    }
    
    @IBAction func openCompanyInfo(sender: AnyObject) {

        guard self.reason != .OneCompany else {
            
            return
        }
        
        if let controller =  self.instantiateViewControllerWithIdentifierOrNibName("CompanyInfoController") as? TCompanyInfoTableViewController {
            
            let company = self.selectedMarker?.userData as? TCompanyAddress
            
            controller.company = company
            
            if let image = self.images?.filter({$0.id == company?.companyImageId.value}).first {
                
                controller.companyImage = image
                
                controller.makeOrderNavigationAction = {
                    
                    if let controller = self.instantiateViewControllerWithIdentifierOrNibName("MenuController") as? TCompanyMenuTableViewController {
                        
                        controller.company = company
                        controller.companyImage = image
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
                
                controller.openMapNavigationAction = {
                    
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Private methods
    
    private func displayCompanyInfo(marker: GMSMarker) {
        
        marker.icon = GMSMarker.markerImageWithColor(UIColor(hexString: kHexMainPinkColor))
        let company = marker.userData as! TCompanyAddress
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        transition.duration = 0.3
        self.companyView.layer.addAnimation(transition, forKey: "setInfo")
        
        self.companyTitle.text = company.companyTitle
        self.companyAddress.text = company.title
        self.companyInfo.text = company.companyCategoryTitle + ", " + String(Int(company.distance)) + " m"
        
        if let image = self.images?.filter({$0.id == company.companyImageId.value}).first {
            
            let filter = AspectScaledToFillSizeFilter(size: self.companyImage.frame.size)
            self.companyImage.af_setImageWithURL(NSURL(string: image.url)!, filter: filter, imageTransition: .CrossDissolve(0.5))
        }
        
        if (self.companyView.layer.shadowPath == nil) {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.companyView.layer.shadowPath = UIBezierPath(rect: self.companyView.layer.bounds).CGPath
                self.companyView.layer.shadowOffset = CGSize(width: 2, height: 1)
                self.companyView.layer.shadowOpacity = 0.5
            }
        }
        
        self.selectedMarker = marker
        self.companyView.alpha = 1
    }
}
