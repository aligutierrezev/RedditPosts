//
//  DetailsViewModel.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import Foundation
import Combine

class DetailsViewModel: ObservableObject {
    @Published var post: RedditPost.Data
    @Published var comments: [String] = []

    private let networkClient: NetworkClient
    private var cancellables = Set<AnyCancellable>()
    
    init(post: RedditPost.Data, networkClient: NetworkClient) {
        self.post = post
        self.networkClient = networkClient
    }
    
    func fetchComments() {
        let request = APIRequest(path: .comments(postId: post.id))
        networkClient.perform(request, decodeTo: [RedditCommentResponse].self)
            .compactMap { responseArray in
                responseArray.last?.data.children.prefix(5).compactMap { $0.data.body }
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching comments: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] comments in
                self?.comments = comments.isEmpty ? ["No comments available."] : comments
            })
            .store(in: &cancellables)
    }
}
