//
//  Place.swift
//  LocationManager
//
//  Created by Francesca MACDONALD on 2023-08-31.
//

import Foundation
import MapKit

struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    var address: String {
        let placemark = self.mapItem.placemark
        var cityAndState = ""
        var address = ""
        
        cityAndState = placemark.locality ?? "" //city
        if let state = placemark.administrativeArea {
            cityAndState = cityAndState.isEmpty ? state : "\(cityAndState), \(state))"
        }
        address = placemark.subThoroughfare ?? "" //address - street #
        if let street = placemark.thoroughfare {
            // just show the street unless there is a street #
            address = address.isEmpty ? street : "\(address) \(street)"
        
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            //no address so just city and state
            address = cityAndState
        } else {
            // no cityAndState so just adress, otherwise adress and cityAndState
            address = cityAndState
                .isEmpty ?address : "\(address), \(cityAndState)"
        }
        return address
    }
    
    var latitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.latitude
    }
    var longitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.longitude
    }
}
