//
//  ReviewView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-09-01.
//

import SwiftUI
import Firebase

struct ReviewView: View {
    @StateObject var reviewVM = ReviewViewModel()
    @State var spot: Spot
    @State var review: Review
    @State var postedByThisUser = false
    @State var rateOrReviewString = "Click To Rate:"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack{
            VStack(alignment: .leading) {
                Text(spot.name)
                    .font(.title)
                    .bold()
                    .lineLimit(1)
                Text(spot.address)
                    .padding(.bottom)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(rateOrReviewString)
                .font(postedByThisUser ? .title2 : .subheadline)
                .bold(postedByThisUser)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal)
            
            StarSelectionView(rating: $review.rating)
                .disabled(!postedByThisUser)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2 : 0)
                }
            .padding(.bottom)
            
            VStack (alignment: .leading) {
                Text("Review Title")
                    .bold()
                TextField("title", text: $review.title)
                    .padding(.horizontal, 6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2 : 0.3)
                    }
            }
            .padding(.horizontal)
            .disabled(!postedByThisUser)
            VStack (alignment: .leading) {
                Text("Review")
                    .bold()
                TextField("review", text: $review.body, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 6)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2 : 0.3)
                    }
                    
            }
            .padding(.horizontal)
            Spacer()
            
        }
        .onAppear {
            if review.reviewer == Auth.auth().currentUser?.email {
                postedByThisUser = true
            } else {
                let reviewPostedOn = review.postedOn.formatted(date: .numeric, time: .omitted)
                rateOrReviewString = "by: \(review.reviewer) on \(review.postedOn)"
            }
        }
        .navigationBarBackButtonHidden(postedByThisUser)
        .toolbar {
            if postedByThisUser {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await reviewVM.saveReview(spot: spot, review: review)
                            if success {
                                dismiss()
                            } else {
                                print("ERROR: saviing data in ReviewView")
                            }
                        }
                    }
                }
                if review.id != nil {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button {
                            Task {
                                let success = await reviewVM.deleteReview(spot: spot, review: review)
                                if success {
                                    dismiss()
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReviewView(spot: Spot(name: "Shake Shack", address: "49 Boyleton St., Chesnut Hill, MA6723"), review: Review())
        }
    }
}
