//
//  ImageDownloader.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import UIKit

class ImageDownloader {

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
        return task
    }
}
