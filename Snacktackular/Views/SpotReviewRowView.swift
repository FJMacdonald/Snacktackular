//
//  SpotReviewRowView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-09-05.
//

import SwiftUI

struct SpotReviewRowView: View {
    @State var review: Review
    var body: some View {
        VStack(alignment: .leading) {
            Text(review.title)
                .font(.title2)
            HStack {
                StarSelectionView(rating: $review.rating, interactive: false, font: .callout)
                Text(review.body)
                    .font(.callout)
                    .lineLimit(1)
            }
        }
    }
}

struct SpotReviewRowView_Previews: PreviewProvider {
    static var previews: some View {
        SpotReviewRowView(review: Review(title: "Fantasic Food", body: "Love this place so much.  surly staff tho"))
    }
}
