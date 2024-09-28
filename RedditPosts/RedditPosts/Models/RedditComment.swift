//
//  RedditComment.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 27/09/24.
//

import Foundation

struct RedditCommentResponse: Decodable {
    let data: CommentData
}

struct CommentData: Decodable {
    let children: [CommentChild]
}

struct CommentChild: Decodable {
    let data: Comment
}

struct Comment: Decodable {
    let body: String?
}
