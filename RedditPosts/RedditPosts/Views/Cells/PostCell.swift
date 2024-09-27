//
//  PostCell.swift
//  RedditPosts
//
//  Created by Ali Gutierrez on 26/09/24.
//

import UIKit

class PostCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let thumbnailImageView = UIImageView()
    private let upvotesLabel = UILabel()
    private let commentsLabel = UILabel()
    private let horizontalStackView = UIStackView()

    private var currentImageTask: URLSessionDataTask?
    private var currentImageURL: URL?
    private let imageDownloader = ImageDownloader()
    private var imageHeightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        thumbnailImageView.image = nil
        thumbnailImageView.isHidden = true
        upvotesLabel.text = nil
        commentsLabel.text = nil
        currentImageURL = nil
        currentImageTask?.cancel()
        currentImageTask = nil
        imageHeightConstraint?.isActive = false
        imageHeightConstraint = nil
    }

    private func setupUI() {
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.isHidden = true
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        upvotesLabel.font = UIFont.systemFont(ofSize: 14)
        upvotesLabel.textColor = .gray
        
        commentsLabel.font = UIFont.systemFont(ofSize: 14)
        commentsLabel.textColor = .gray
        
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .leading
        horizontalStackView.spacing = 8
        horizontalStackView.addArrangedSubview(commentsLabel)
        horizontalStackView.addArrangedSubview(upvotesLabel)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            thumbnailImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            horizontalStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with post: RedditPost.Data) {
        titleLabel.text = post.title
        upvotesLabel.text = "Upvotes: \(post.ups)"
        commentsLabel.text = "Comments: \(post.num_comments)"
        
        if let thumbnailURLString = post.thumbnail, let url = URL(string: thumbnailURLString) {
            currentImageURL = url
            let nsURL = url as NSURL
            
            if let cachedImage = ImageCache.shared.getImage(for: nsURL) {
                thumbnailImageView.image = cachedImage
                thumbnailImageView.isHidden = false
                setImageAspectRatio(post: post)
            } else {
                thumbnailImageView.isHidden = true
                currentImageTask = imageDownloader.downloadImage(from: url) { [weak self] image in
                    guard let self = self, let image = image else { return }
                    ImageCache.shared.setImage(image, for: nsURL)
                    
                    DispatchQueue.main.async {
                        if self.currentImageURL == url {
                            self.thumbnailImageView.image = image
                            self.thumbnailImageView.isHidden = false
                            self.setImageAspectRatio(post: post)
                            self.updateCellLayout()
                        }
                    }
                }
            }
        } else {
            thumbnailImageView.isHidden = true
        }
    }

    private func setImageAspectRatio(post: RedditPost.Data) {
        imageHeightConstraint?.isActive = false
        
        if let thumbnailWidth = post.thumbnail_width, let thumbnailHeight = post.thumbnail_height {
            let aspectRatio = CGFloat(thumbnailHeight) / CGFloat(thumbnailWidth)
            
            imageHeightConstraint = thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: aspectRatio)
            imageHeightConstraint?.isActive = true
        }
    }

    private func updateCellLayout() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        if let tableView = self.superview as? UITableView {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
