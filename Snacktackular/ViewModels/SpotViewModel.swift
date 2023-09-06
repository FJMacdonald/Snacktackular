//
//  SpotViewModel.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-08-30.
//

import Foundation
import FirebaseFirestore
import UIKit
import FirebaseStorage

@MainActor
class SpotViewModel: ObservableObject {
    @Published var spot = Spot()
    
    func saveSpot(spot: Spot) async -> Bool {
        let db = Firestore.firestore()
        if let id = spot.id { // spot exists so save
            do {
                try await db.collection("spots").document(id).setData(spot.dictionary)
                print("Data updated sucessfully")
                return true
            } catch {
                print("ERROR: could not update data in spots \(error.localizedDescription)")
                return false
            }
        } else {
            //no id means this is a new spot to add
            do {
                //addDocument names the doc with unique characters and puts this in the @DocumentID property, which we have named id, making the struct identifiable.
                let documentRef = try await db.collection("spots").addDocument(data: spot.dictionary)
                self.spot = spot
                self.spot.id = documentRef.documentID
                print("Data added sucessfully")
                return true
            } catch {
                print("ERROR: could not add data in spots \(error.localizedDescription)")
                return false
            }
        }
    }
    func saveImage(spot: Spot, photo: Photo, image: UIImage) async -> Bool {
        guard let spotID = spot.id else {
            print("ERROR: spot.id == nil")
            return false
        }
        var photoName = UUID().uuidString //the name of the image file
        if photo.id != nil {
            //if updating the descriptive info, will resave the photo.
            photoName = photo.id!
        }
        let storage = Storage.storage() //creates a firebase storage instance
        let storageRef = storage.reference().child("\(spotID)/\(photoName).jpeg")
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.2) else {
            print("ERROR: could not resize image")
            return false
        }
        // metadata is data the describes other data.
        // metadata that defiines a cloud storage file as an image allows the image to be viewable in the browser console.
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg" //also works with png
        
        var imageURLString = "" // set after the image is saved
        do {
            let _ = try await storageRef.putDataAsync(resizedImage, metadata: metadata)
            print("Image saved")
            do {
                let imageURL = try await storageRef.downloadURL()
                imageURLString = "\(imageURL)" // will be saved to Cloud Ffirestore as part of the document in 'photos' collection
            } catch {
                print("ERROR: could not get imageURL after saving image \(error.localizedDescription)")
                return false
            }
        } catch {
            print("ERROR: uploading image to firbase storage")
            return false
        }
        
        //now save to the "photos" collection of the spot document "spotID"
        let db = Firestore.firestore()
        let collectionString = "spots/\(spotID)/photos"
        do {
            var newPhoto = photo
            newPhoto.imageURLString = imageURLString
            try await db.collection(collectionString).document(photoName).setData(newPhoto.dictionary)
            print("Data updated successfully")
            return true
        } catch {
            print("ERROR: could not update data in 'photos' for spotid \(spotID)")
            return false
        }
    }
}
