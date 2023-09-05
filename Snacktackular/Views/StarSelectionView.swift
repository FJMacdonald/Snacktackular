//
//  StarSelectionView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-09-01.
//

import SwiftUI

struct StarSelectionView: View {
    @Binding var rating: Int
    @State var interactive = true
    var font: Font = .largeTitle
    var highestRating = 5
    let unselected = Image(systemName: "star")
    let selected = Image(systemName: "star.fill")
    let fillColor: Color = .red
    let emptyColor: Color = .gray
    
    var body: some View {
        HStack {
            ForEach(1...highestRating, id: \.self) { number in
                showStar(for: number)
                    .foregroundColor(number <= rating ? fillColor : emptyColor)
                    .onTapGesture {
                        if interactive {
                            rating = number
                        }
                    }
            }
            .font(font)
        }
    }
    func showStar(for number: Int) -> Image {
        if number > rating {
            return unselected
        } else {
            return selected
        }
    }
}

struct StarSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StarSelectionView(rating: .constant(4))
    }
}
