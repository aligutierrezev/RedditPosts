//
//  RedditPostsApp.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import SwiftUI

@main
struct RedditPostsApp: App {
    var body: some Scene {
        WindowGroup {
            let homeViewModel = HomeViewModel(networkClient: URLSessionNetworkClient())
            let homeViewController = HomeViewController(viewModel: homeViewModel)
            
            UIViewControllerWrapper(viewController: homeViewController)
        }
    }
}


struct UIViewControllerWrapper: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
