//
//  CompanyAddressExtension.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 05/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

extension TCompanyAddress {
    
    var todayWorkingHours: [String]? {
        
        if self.workingTime.count < 6 {
            
            return nil
        }
        
        let correctionArray = [7, 1, 2, 3, 4, 5, 6]
        
        let weekDay = NSDate().weekday
        
        let index = correctionArray[weekDay - 1]
        
        return self.workingTime[index - 1]
    }
}
