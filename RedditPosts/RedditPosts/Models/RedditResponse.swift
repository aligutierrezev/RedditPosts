//
//  RedditResponse.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import Foundation

struct RedditResponse: Decodable {
    struct Data: Decodable {
        let children: [RedditPost]
    }
    
    let data: Data
}
