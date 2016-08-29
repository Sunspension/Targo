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
    
    var images: [TCompanyImage]?
    
    var selectedMarker: GMSMarker?
    
    var didsetLocation = false
    
    var companies: [TCompanyAddress]?
    
    var reason = OpenMapsReasonEnum.AllCompanies
    
    
    var loading = false

    
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
        
        
        if self.reason == .OneCompany {
            
            self.addMarkers()
        }
        else {
            
            self.loading = true
        }
    }    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if self.loading {
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
        }
    }
    
    func loadCompanies() {
        
        self.loading = true
        
        Api.sharedInstance.loadCompanyAddresses(self.userLocation!,
            pageNumber: 1, pageSize: 1000)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                if let superview = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
                self.loading = false
                
                self.images = companyPage.images
                self.companies = companyPage.companies
                
                self.addMarkers()
                
                }).onFailure(callback: { [unowned self] error in
                    
                    self.loading = false
                    
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    print(error)
                })
    }
    
    func addMarkers() {
        
        if let companies = self.companies {
            
            for company in companies {
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
                marker.title = company.companyTitle
                marker.snippet = company.companyDescription
                marker.userData = company
                marker.map = self.mapView
                marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
                marker.appearAnimation = kGMSMarkerAnimationPop
                
                if reason == .OneCompany {
                    
                    self.mapView.camera = GMSCameraPosition.cameraWithTarget(marker.position, zoom: 13)
                }
            }
        }
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        self.selectedMarker?.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        
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
            
            self.companyView.layer.shadowPath = UIBezierPath(rect: self.companyView.layer.bounds).CGPath
            self.companyView.layer.shadowOffset = CGSize(width: 2, height: 1)
            self.companyView.layer.shadowOpacity = 0.5
        }

        self.selectedMarker = marker
        self.companyView.alpha = 1
        
        return true
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        self.companyView.alpha = 0
        self.selectedMarker?.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        self.selectedMarker = nil
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let newValue = change {
            
            if let location: CLLocation = newValue[NSKeyValueChangeNewKey] as? CLLocation {
                
                if self.reason == .AllCompanies {
                    
                    self.userLocation = location
                    
                    self.mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 10)
                    
                    self.loadCompanies()
                }
                else {
                    
                    self.addMarkers()
                }
                
                self.mapView.removeObserver(self, forKeyPath: "myLocation")
            }
        }
    }
    
    @IBAction func openCompanyInfo(sender: AnyObject) {

        guard self.reason == .OneCompany else {
            
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
}
