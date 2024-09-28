//
//  HomeViewModel.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    let networkClient: NetworkClient
    private var cancellables = Set<AnyCancellable>()
    
    @Published var posts: [RedditPost.Data] = []
    @Published var error: Error?
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchPosts() {
        let request = APIRequest(path: .root)
        networkClient.perform(request, decodeTo: RedditResponse.self)
            .map { $0.data.children.map { $0.data } }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] posts in
                self?.posts = posts
            })
            .store(in: &cancellables)
    }
}
