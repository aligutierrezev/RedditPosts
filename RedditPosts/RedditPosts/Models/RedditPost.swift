//
//  RedditPost.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import Foundation

struct RedditPost: Decodable {
    struct Data: Decodable {
        let title: String
        let thumbnail: String?
        let thumbnail_width: Int?
        let thumbnail_height: Int?
        let num_comments: Int
        let ups: Int
        let selftext: String?
    }
    
    let data: Data
}
