//
//  TCompaniesOnMapsViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 23/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import GoogleMaps
import SignalKit

class TCompaniesOnMapsViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet weak var companyView: UIView!
    
    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var companyAddress: UILabel!
    
    @IBOutlet weak var companyInfo: UILabel!
    
    @IBOutlet weak var buttonInfo: UIButton!
    
    
    var companyImages: [TCompanyImage] = []
    
    
    var selectedMarker: GMSMarker?
    
    var didsetLocation = false
    
    var companiesPage: TCompaniesPage?
    
    let bag = DisposableBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "maps_title".localized
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        mapView.delegate = self
        
        mapView.observe().keyPath("myLocation", value: mapView.myLocation).next { myLocation in
            
            if let location = myLocation {
                
                if self.didsetLocation {
                    
                    return
                }
                
                self.didsetLocation = true
                self.mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 12)
            }
            
        }.disposeWith(bag)
        
        mapView.myLocationEnabled = true
        
        self.view = mapView
        
        if let companies = self.companiesPage?.companies {
            
            for company in companies {
                
                weak var wcompany = company
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
                marker.title = company.companyTitle
                marker.snippet = company.companyDescription
                marker.userData = wcompany
                marker.map = mapView
                marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
            }
        }
        
        self.mapView.bringSubviewToFront(self.companyView)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage(named: "icon-info"), forState: .Normal)
        button.addTarget(self, action: #selector(TCompaniesOnMapsViewController.openCompanyInfo), forControlEvents: .TouchUpInside)
        
        self.companyView.alpha = 0
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        self.selectedMarker?.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        
        marker.icon = GMSMarker.markerImageWithColor(UIColor(hexString: kHexMainPinkColor))
        let company = marker.userData as! TCompany
        
        self.companyTitle.text = company.companyTitle
        self.companyAddress.text = company.title
        self.companyInfo.text = company.companyCategoryTitle + ", " + company.distance + " m"
        
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
    
    @IBAction func openCompanyInfo(sender: AnyObject) {
        
        if let controller =  self.instantiateViewControllerWithIdentifierOrNibName("CompanyInfoController") as? TCompanyInfoTableViewController {
            
            let company = self.selectedMarker?.userData as? TCompany
            
            controller.company = company
            
            if let image = self.companyImages.filter({$0.id == company?.companyImageId.value}).first {
                
                controller.companyImageUrlString = image.url
                controller.enableButtonMakeOrder = true
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
