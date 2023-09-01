//
//  PlaceViewModel.swift
//  LocationManager
//
//  Created by Francesca MACDONALD on 2023-08-31.
//

import Foundation
import MapKit

@MainActor
class PlaceViewModel: ObservableObject {
    @Published var places: [Place] = []
    
    func search(text: String, region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response else {
                print("ERROR: \(error?.localizedDescription ?? "Unknowm error")")
                return
            }
                      
            self.places = response.mapItems.map(Place.init)
        }
    }
}
