//
//  Photo.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-09-06.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = "" //url for loading image
    var description = ""
    var reviewer = Auth.auth().currentUser?.email ?? ""
    var postedOn = Date()
    
    var dictionary: [String: Any] {
        return ["imageURLString": imageURLString, "description": description, "reviewer": reviewer, "postedOn": Timestamp(date: Date())]
    }
}
