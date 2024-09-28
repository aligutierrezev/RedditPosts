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
                if let thumbnailURL = viewModel.post.url_overridden_by_dest, let url = URL(string: thumbnailURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
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

    
