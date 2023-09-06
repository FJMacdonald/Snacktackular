//
//  PhotoView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-09-06.
//

import SwiftUI
import FirebaseAuth

struct PhotoView: View {
    @EnvironmentObject var spotVM: SpotViewModel
    @Binding var photo: Photo
    var uiImage: UIImage // no @State as it won't change.
    @State var spot: Spot
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                TextField("Description", text: $photo.description)
                    .textFieldStyle(.roundedBorder)
                    .disabled(Auth.auth().currentUser?.email != photo.reviewer)
                
                Text("by: \(photo.reviewer) on: \(photo.postedOn.formatted(date: .numeric, time: .omitted))")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding()
        }
        .toolbar {
            if Auth.auth().currentUser?.email == photo.reviewer {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        Task {
                            let success = await spotVM.saveImage(spot: spot, photo: photo, image: uiImage)
                            if success {
                                dismiss()
                            }
                        }
                    }
                }
            } else {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(photo: .constant(Photo()), uiImage: UIImage(named: "piizza") ?? UIImage(), spot: Spot())
            .environmentObject(SpotViewModel())
    }
}
