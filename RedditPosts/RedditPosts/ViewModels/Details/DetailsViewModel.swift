//
//  DetailsViewModel.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import Foundation

class DetailsViewModel: ObservableObject {
    let post: RedditPost.Data
    
    init(post: RedditPost.Data) {
        self.post = post
    }
}
