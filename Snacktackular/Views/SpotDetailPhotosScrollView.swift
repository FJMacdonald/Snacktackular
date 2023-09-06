//
//  SpotDetailPhotosScrollView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-09-06.
//

import SwiftUI

struct SpotDetailPhotosScrollView: View {
//    struct FakePhoto: Identifiable {
//        let id = UUID().uuidString
//        var imageURLString = "https://firebasestorage.googleapis.com:443/v0/b/snacktactular-a1697.appspot.com/o/uKMB8E3ImoLW2ul7M6zb%2FC988CAF8-AB14-449C-B874-2DC5D839206B.jpeg?alt=media&token=7053b440-f93f-48a2-9c4d-b84cfa1ca5c8"
//        }
//    let photos = [FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto(), FakePhoto()]
    @State private var showPhotoViewerView = false
    @State private var uiImage = UIImage()
    @State private var selectedPhoto = Photo()
    var photos: [Photo]
    var spot: Spot

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack (spacing: 4) {
                ForEach(photos) { photo in
                    
                    let imageURL = URL(string: photo.imageURLString) ?? URL(string: "")
                    AsyncImage(url: imageURL) {image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .onTapGesture {
                                selectedPhoto = photo
                                let renderer = ImageRenderer(content: image)
                                uiImage = renderer.uiImage ?? UIImage()
                                showPhotoViewerView.toggle()
                            }
                    } placeholder: {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    }
                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 4)
        .sheet(isPresented: $showPhotoViewerView) {
            PhotoView(photo: $selectedPhoto, uiImage: uiImage, spot: spot)
        }
    }
}

struct SpotDetailPhotosScrollView_Previews: PreviewProvider {
    static var previews: some View {
        SpotDetailPhotosScrollView(photos: [Photo(imageURLString: "https://firebasestorage.googleapis.com:443/v0/b/snacktactular-a1697.appspot.com/o/uKMB8E3ImoLW2ul7M6zb%2FC988CAF8-AB14-449C-B874-2DC5D839206B.jpeg?alt=media&token=7053b440-f93f-48a2-9c4d-b84cfa1ca5c8")], spot: Spot(id: "uKMB8E3ImoLW2ul7M6zb"))
    }
}
