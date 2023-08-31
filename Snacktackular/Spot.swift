//
//  Spot.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-08-30.
//

import Foundation
import FirebaseFirestoreSwift

struct Spot: Identifiable, Codable {
/*
 @DocumentID is a property wrapper type that marks a DocumentReference? or String? field to be populated with a document identifier when it is read.
    
Apply the @DocumentID annotation to a DocumentReference? or String? property in a Codable object to have it populated with the document identifier when it is read and decoded from Firestore.
Important
 The name of the property annotated with @DocumentID must not match the name of any fields in the Firestore document being read or else an error will be thrown. For example, if the Codable object has a property named firstName annotated with @DocumentID, and the Firestore document contains a field named firstName, an error will be thrown when attempting to decode the document.
 Important
 Trying to encode/decode this type using encoders/decoders other than Firestore.Encoder throws an error.
 Important
 When writing a Codable object containing an @DocumentID annotated field, its value is ignored. This allows you to read a document from one path and write it into another without adjusting the value here.
*/
    @DocumentID var id: String?
    var name = ""
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitude]
    }
}
