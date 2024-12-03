//
//  RedditPost.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import Foundation

struct RedditPost: Decodable {
    struct Data: Decodable {
        struct Preview: Decodable {
            struct Image: Decodable {
                struct Source: Decodable {
                    let url: String
                    let width: Int
                    let height: Int
                }
                let source: Source
            }
            let images: [Image]
        }

        let id: String
        let title: String
        let thumbnail: String?
        let url_overridden_by_dest: String?
        let thumbnail_width: Int?
        let thumbnail_height: Int?
        let num_comments: Int
        let ups: Int
        let selftext: String?
        let preview: Preview?
    }
    
    let data: Data
}
