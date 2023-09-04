//
//  SpotDetailView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-08-30.
//

import SwiftUI
import MapKit
import FirebaseFirestoreSwift

struct SpotDetailView: View {
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
    }
    @EnvironmentObject var spotVM: SpotViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    @State var spot: Spot
    @State private var showPlaceLookupSheet = false
    @State private var showReviewViewSheet = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    @State private var showSaveAlert = false
    @State private var showingAsSheet = false
    //The variiable below doesn't have the correct path, but will be changed in .onAppear
    @FirestoreQuery(collectionPath: "sports") var reviews: [Review]
    //you don't have to provide values for initialized properties but youu can...
    var previewRunning = false
    
    let regionSize = 500.0 //meters
    
    var body: some View {
        VStack {
            Group {
                TextField("Name", text: $spot.name)
                    .font(.title)
                TextField("Address", text: $spot.address)
                    .font(.title2)
            }
            .disabled(spot.id != nil)
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: spot.id == nil ? 2 : 0)
            }
            .padding(.horizontal)
            
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            }
            .frame(height: 250)
            .onChange(of: spot) { _ in
                annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
            }
            
            List {
                Section {
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot: spot, review: review)
                        } label: {
                            Text(review.title)//TODO: Build a custom cell showing stars, title and body
                        }
                    }
                    
                } header: {
                    HStack {
                        Text("Avg. Rating:")
                            .font(.title2)
                            .bold()
                        Text("4.5")
                            .font(.title)
                            .fontWeight(.black)
                            .tint(Color("SnackColor"))
                        Spacer()
                        Button("Rate It") {
                            if spot.id == nil {
                                showSaveAlert.toggle()
                            } else {
                                showReviewViewSheet.toggle()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .bold()
                        .tint(Color("SnackColor"))
                        
                    }
                }
                .headerProminence(.increased)
            }
            .listStyle(.plain)
            
            Spacer()
        }
        .onAppear {
            //this is to prevent the preview crash
            if !previewRunning && spot.id != nil {
                //reset the path correctly
                $reviews.path = "spots/\(spot.id ?? "")/reviews"
                print("reviews.pth = \($reviews.path)")
            } else {
                // spot.id starts out as niil
                showingAsSheet = true
            }
            if spot.id != nil {
                //if we have a spot, center the mapregion on the spot
                mapRegion = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
            } else {
                Task { //if not embedded in task , map update might not show}
                    mapRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                }
            }
            annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(spot.id == nil)
        .toolbar {
            if showingAsSheet {
                if spot.id == nil {
                    //new spot, so show cancel/save buttons
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Save") {
                            Task {
                                let success = await spotVM.saveSpot(spot: spot)
                                if success {
                                    dismiss()
                                } else {
                                    print("ERROR saving spot")
                                }
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button {
                            showPlaceLookupSheet.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                            Text("Lookup Place")
                        }
                        
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        }
        .sheet(isPresented: $showReviewViewSheet) {
            NavigationStack {
                ReviewView(spot: spot, review: Review())
            }
        }
        .alert("CCannot Rate Place Unless It is Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await spotVM.saveSpot(spot: spot)
                    //This updates the spot's id after saving
                    spot = spotVM.spot
                    if success {
                        // the path has to be updated after saving a spot or we wouldn't be able to show new reviews added
                        $reviews.path = "spots/\(spot.id ?? "")/reviews"
                        showReviewViewSheet.toggle()
                    } else {
                        print("ERROR saving spot")
                    }
                }
           }
        }

    }
}


struct SpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpotDetailView(spot: Spot(), previewRunning: true)
                .environmentObject(SpotViewModel())
                .environmentObject(LocationManager())
        }
    }
}
