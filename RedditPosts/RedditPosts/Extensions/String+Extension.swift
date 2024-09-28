//
//  String+Extension.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 27/09/24.
//

import UIKit

extension String {
    var decodedURL: URL? {
        let decodedString = self.replacingOccurrences(of: "&amp;", with: "&")
        return URL(string: decodedString)
    }
}
