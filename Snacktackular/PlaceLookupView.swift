//
//  PlaceLookupView.swift
//  LocationManager
//
//  Created by Francesca MACDONALD on 2023-08-31.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var placeVM = PlaceViewModel() // can be initialized as @StateObjecct if this is the first or only place this viewmodel is used
    @State private var seaarcchText = ""
    @Binding var returnedPlace: Place
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(placeVM.places) { place in
                VStack {
                    Text(place.name)
                        .font(.title2)
                    Text(place.address)
                        .font(.callout)
                }
                .onTapGesture {
                    returnedPlace = place
                    dismiss()
                }
            }
            .listStyle(.plain)
            .searchable(text: $seaarcchText)
            .onChange(of: seaarcchText, perform: { text in
                if !text.isEmpty {
                    placeVM.search(text: text, region: locationManager.region)
                } else {
                    placeVM.places = []
                }
            })
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlaceLookupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlaceLookupView(returnedPlace: .constant(Place(mapItem: MKMapItem())))
                .environmentObject(LocationManager())
        }
    }
}
