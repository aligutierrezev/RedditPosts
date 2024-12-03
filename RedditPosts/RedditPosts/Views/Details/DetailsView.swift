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
                if let preview = viewModel.post.preview,
                   let originalImageURL = preview.images.first?.source.url.decodedURL {
                    AsyncImage(url: originalImageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        case .failure(_):
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                Text(viewModel.post.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
                
                HStack {
                    Label("Upvotes: \(viewModel.post.ups)", systemImage: "arrow.up")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Label("Comments: \(viewModel.post.num_comments)", systemImage: "bubble.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let bodyText = viewModel.post.selftext, !bodyText.isEmpty {
                    Text(bodyText)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                
                Text("Top Comments")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.comments, id: \.self) { comment in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(comment)
                                .font(.body)
                                .lineLimit(3)
                                .truncationMode(.tail)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Post Details")
        .background(Color(UIColor.systemBackground))
        .onAppear {
            viewModel.fetchComments()
        }
    }
}
