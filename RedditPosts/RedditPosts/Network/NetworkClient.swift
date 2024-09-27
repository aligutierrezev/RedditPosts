//
//  NetworkClient.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum RedditAPIPath: String {
    case root = "/.json"
}

protocol Request {
    var baseURL: URL { get }
    var path: RedditAPIPath { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

extension Request {
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        return nil
    }
    
    var url: URL {
        return baseURL.appendingPathComponent(path.rawValue)
    }
}

struct APIRequest: Request {
    var baseURL: URL
    var path: RedditAPIPath
    var method: HTTPMethod
    var headers: [String: String]?
    var body: Data?
    
    init(baseURL: URL = Constants.API.baseURL,
         path: RedditAPIPath,
         method: HTTPMethod = .get,
         headers: [String: String]? = nil,
         body: Data? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
    }
}

protocol NetworkClient {
    func perform<T: Decodable>(_ request: Request, decodeTo type: T.Type) -> AnyPublisher<T, Error>
}

class URLSessionNetworkClient: NetworkClient {
    private var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func perform<T: Decodable>(_ request: Request, decodeTo type: T.Type) -> AnyPublisher<T, Error> {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
