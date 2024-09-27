//
//  HomeViewController.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    private var viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    var posts: [RedditPost.Data] = []
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchPosts()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.refreshControl = refreshControl
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
    }
    
    private func bindViewModel() {
        viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.refreshControl.endRefreshing()
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshData() {
            viewModel.fetchPosts()
        }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = viewModel.posts[indexPath.row]
        cell.configure(with: post)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: link to detail View
    }
}

extension HomeViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
            let urls = indexPaths.compactMap { indexPath -> URL? in
                guard indexPath.row < posts.count else { return nil }
                return URL(string: posts[indexPath.row].thumbnail ?? "")
            }

            ImagePrefetcher.shared.prefetch(urls: urls)
        }
    
}
