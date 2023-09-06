//
//  SpotDetailView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-08-30.
//

import SwiftUI
import MapKit
import FirebaseFirestoreSwift
import PhotosUI

struct SpotDetailView: View {
    enum ButtonPressed {
        case review, photo
    }
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
    }
    @EnvironmentObject var spotVM: SpotViewModel
    @EnvironmentObject var locationManager: LocationManager
    //The variiable below doesn't have the correct path, but will be changed in .onAppear
    @FirestoreQuery(collectionPath: "spots") var reviews: [Review]
    @FirestoreQuery(collectionPath: "spots") var photos: [Photo]
    @Environment(\.dismiss) private var dismiss
    @State var spot: Spot
    @State var newPhoto = Photo()
    @State private var showPlaceLookupSheet = false
    @State private var showReviewViewSheet = false
    @State private var showPhotoViewSheet = false
    @State private var showSaveAlert = false
    @State private var showingAsSheet = false
    @State private var buttonPressed = ButtonPressed.review
    @State private var uiImageSelected = UIImage()
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    @State private var selectedPhoto: PhotosPickerItem?
    //you don't have to provide values for initialized properties but youu can...
    var previewRunning = false
    
    let regionSize = 500.0 //meters

    var avgRating: String {
        guard reviews.count != 0 else {
            return "-.-"
        }
        //reduce to single value, starting from 0 and adding each subsequent rating
        let averageValue = Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
        return String(format: "%.1f", averageValue)
    }
    
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
            
            SpotDetailPhotosScrollView(photos: photos, spot: spot)
            HStack {
                Group {
                    Text("Avg. Rating:")
                        .font(.title2)
                        .bold()
                    Text(avgRating)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(Color("SnackColor"))
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                Spacer()
                Group {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                        Image(systemName: "photo")
                        Text("Photo")
                    }
                    .onChange(of: selectedPhoto) { newValue in
                        Task {
                            do {
                                if let image = try await newValue?.loadTransferable(type: Image.self) {
                                    uiImageSelected = ImageRenderer(content: image).uiImage ?? UIImage()
                                    print("successfully selected image")
                                    //clear out contents if you add more than 1 photo
                                    newPhoto = Photo()
                                    buttonPressed = .photo
                                    if spot.id == nil {
                                        showSaveAlert.toggle()
                                    } else {
                                        showPhotoViewSheet.toggle()
                                    }
                                }
                            } catch {
                                print("ERROR: selecting image failed \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    Button(action: {
                        buttonPressed = .review
                        if spot.id == nil {
                            showSaveAlert.toggle()
                        } else {
                            showReviewViewSheet.toggle()
                        }
                    }, label: {
                        Image(systemName: "star.fill")
                        Text("Rate")
                    })
                }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(Color("SnackColor"))
                
            }
            .font(.caption)
            .padding(.horizontal)
            .lineLimit(1)
            .minimumScaleFactor(0.5)

            
            List {
                Section {
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot: spot, review: review)
                        } label: {
                            SpotReviewRowView(review: review)
                        }
                    }
                    
                }

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
                $photos.path = "spots/\(spot.id ?? "")/photos"
                print("photos.pth = \($photos.path)")
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
        .sheet(isPresented: $showPhotoViewSheet) {
            NavigationStack {
                PhotoView(photo: $newPhoto, uiImage: uiImageSelected, spot: spot)
            }
        }
        .alert("Cannot Rate Place Unless It is Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await spotVM.saveSpot(spot: spot)
                    //This updates the spot's id after saving
                    spot = spotVM.spot
                    if success {
                        // the path has to be updated after saving a spot or we wouldn't be able to show new reviews added
                        $reviews.path = "spots/\(spot.id ?? "")/reviews"
                        $photos.path = "spots/\(spot.id ?? "")/photos"
                        switch buttonPressed {
                        case .review:
                            showReviewViewSheet.toggle()
                        case .photo:
                            showPhotoViewSheet.toggle()
                        }
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
