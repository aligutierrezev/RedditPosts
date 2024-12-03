//
//  ImagePrefetcher.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import UIKit

class ImagePrefetcher {
    static let shared = ImagePrefetcher()
    private let imageDownloader = ImageDownloader()

    func prefetch(urls: [URL]) {
        for url in urls {
            let nsURL = url as NSURL
            if ImageCache.shared.getImage(for: nsURL) == nil {
                imageDownloader.downloadImage(from: url) { image in
                    if let image = image {
                        ImageCache.shared.setImage(image, for: nsURL)
                    }
                }
            }
        }
    }
}
