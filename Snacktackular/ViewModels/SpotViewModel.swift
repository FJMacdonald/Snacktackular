//
//  SpotViewModel.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-08-30.
//

import Foundation
import FirebaseFirestore

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
}
