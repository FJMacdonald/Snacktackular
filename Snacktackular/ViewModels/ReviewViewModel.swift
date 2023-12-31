//
//  ReviewViewModel.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-09-01.
//

import Foundation
import FirebaseFirestore

@MainActor
class ReviewViewModel: ObservableObject {
    @Published var review = Review()
    
    func saveReview(spot: Spot, review: Review) async -> Bool {
        let db = Firestore.firestore()
        
        guard let spotId = spot.id else {
            print("ERROR: spot.id = nil")
            return false
        }
        let pathString = "spots/\(spotId)/reviews"

        if let id = review.id { // review exists so save
            do {
                try await db.collection(pathString).document(id).setData(review.dictionary)
                print("Data updated sucessfully")
                return true
            } catch {
                print("ERROR: could not update data in reviews \(error.localizedDescription)")
                return false
            }
        } else {
            //no id means this is a new review to add
            do {
                //addDocument names the doc with unique name and puts this in the @DocumentID property, which we have named id, making the struct identifiable.
                try await db.collection(pathString).addDocument(data: review.dictionary)
                print("Data added sucessfully")
                return true
            } catch {
                print("ERROR: could not add data in reviews \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func deleteReview(spot: Spot, review: Review) async -> Bool {
        let db = Firestore.firestore()
        guard let spotID = spot.id, let reviewID = review.id else {
            print("ERROR: spot.id = \(spot.id ?? ""), review.id = \(review.id ?? "") This should not have happened.")
            return false
        }
        do {
            let _ = try await db.collection("spots").document(spotID).collection("reviews").document(reviewID).delete()
            print("Doccument successfully ddeletedd")
            return true
        } catch {
            print("ERROR removing doccument \(error.localizedDescription)")
            return false
        }
    }
}
