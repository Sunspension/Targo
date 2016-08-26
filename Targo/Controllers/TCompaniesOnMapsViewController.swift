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

class TCompaniesOnMapsViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet weak var companyView: UIView!
    
    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var companyAddress: UILabel!
    
    @IBOutlet weak var companyInfo: UILabel!
    
    @IBOutlet weak var companyImage: UIImageView!
    
    
    var companyImages: Set<TCompanyImage>?
    
    var selectedMarker: GMSMarker?
    
    var didsetLocation = false
    
    var companiesPage: TCompanyAddressesPage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
        
        self.title = "maps_title".localized
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        if let companies = self.companiesPage?.companies {
            
            for company in companies {
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
                marker.title = company.companyTitle
                marker.snippet = company.companyDescription
                marker.userData = company
                marker.map = mapView
                marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
            }
        }
        
        self.mapView.bringSubviewToFront(self.companyView)
        self.companyView.alpha = 0
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
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
        self.companyInfo.text = company.companyCategoryTitle + ", " + String(company.distance) + " m"
        
        if let image = self.companyImages?.filter({$0.id == company.companyImageId.value}).first {
            
            let filter = AspectScaledToFillSizeFilter(size: self.companyImage.frame.size)
            self.companyImage.af_setImageWithURL(NSURL(string: image.url)!, filter: filter, imageTransition: .CrossDissolve(0.6))
        }
        
        if (self.companyView.layer.shadowPath == nil) {
            
            self.companyView.layer.shadowPath = UIBezierPath(rect: self.companyView.layer.bounds).CGPath
            self.companyView.layer.shadowOffset = CGSize(width: 2, height: 4)
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
            
            let location: CLLocation = newValue[NSKeyValueChangeNewKey] as! CLLocation
            self.mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 12)
            
            self.mapView.removeObserver(self, forKeyPath: "myLocation")
        }
    }
    
    @IBAction func openCompanyInfo(sender: AnyObject) {
        
        if let controller =  self.instantiateViewControllerWithIdentifierOrNibName("CompanyInfoController") as? TCompanyInfoTableViewController {
            
            let company = self.selectedMarker?.userData as? TCompanyAddress
            
            controller.company = company
            
            if let image = self.companyImages?.filter({$0.id == company?.companyImageId.value}).first {
                
                controller.companyImage = image
                
                controller.makeOrderNavigationAction = {
                    
                    if let controller = self.instantiateViewControllerWithIdentifierOrNibName("MenuController") as? TCompanyMenuTableViewController {
                        
                        controller.company = company
                        controller.companyImage = image
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
