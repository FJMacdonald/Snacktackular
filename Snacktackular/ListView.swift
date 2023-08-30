//
//  ListView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-08-30.
//

import SwiftUI
import Firebase

struct ListView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        List {
            Text("List items will go here")
        }
        .listStyle(.plain)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Sign Out") {
                    do {
                        try Auth.auth().signOut()
                        print("Logout sucessful")
                        dismiss()
                    } catch {
                        print("ERROR: Could not sign out!")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListView()
        }
    }
}
