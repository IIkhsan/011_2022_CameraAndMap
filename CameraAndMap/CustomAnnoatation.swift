//
//  CustomAnnoatation.swift
//  CameraAndMap
//
//  Created by ilyas.ikhsanov on 29.03.2022.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var subtitle: String?
    
    var image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
