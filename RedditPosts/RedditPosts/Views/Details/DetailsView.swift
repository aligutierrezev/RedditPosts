//
//  DetailsView.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject var viewModel: DetailsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let thumbnailURL = viewModel.post.thumbnail, let url = URL(string: thumbnailURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Show a progress view while loading
                        case .success(let image):
                            image
                                .resizable()  // Apply resizable to the Image
                                .scaledToFit() // Scale the image to fit within the frame
                                .frame(width: CGFloat(400), height: CGFloat(400))
                        case .failure(_):
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Text(viewModel.post.title)
                    .font(.title)
                    .padding(.bottom, 8)
                
                Text("Upvotes: \(viewModel.post.ups)")
                Text("Comments: \(viewModel.post.num_comments)")
                if let bodyText = viewModel.post.selftext {
                    Text(bodyText)
                }
            }
            .padding()
        }
        .navigationTitle("Post Details")
    }
}

    
