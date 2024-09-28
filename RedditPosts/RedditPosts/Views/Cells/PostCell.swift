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
    private var aspectRatioConstraint: NSLayoutConstraint?
    private let invalidThumbailImage = ["default", "self", "image", ""]

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
        aspectRatioConstraint?.isActive = false
        imageHeightConstraint = nil
        aspectRatioConstraint = nil
    }

    private func setupUI() {
        // Title Label
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Thumbnail Image View
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.isHidden = true
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Upvotes Label
        upvotesLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        upvotesLabel.textColor = .secondaryLabel
        
        // Comments Label
        commentsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        commentsLabel.textColor = .secondaryLabel
        
        // Horizontal Stack View
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 8
        horizontalStackView.addArrangedSubview(upvotesLabel)
        horizontalStackView.addArrangedSubview(commentsLabel)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(horizontalStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            // Thumbnail Image View Constraints
            thumbnailImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            // Horizontal Stack View Constraints
            horizontalStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 12),
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with post: RedditPost.Data) {
        titleLabel.text = post.title
        upvotesLabel.text = "upvotes: \(post.ups)"
        commentsLabel.text = "comments: \(post.num_comments)"
        
        if let thumbnailURLString = post.thumbnail,
           !invalidThumbailImage.contains(thumbnailURLString),
           let url = URL(string: thumbnailURLString) {
            currentImageURL = url
            let nsURL = url as NSURL
            
            if let cachedImage = ImageCache.shared.getImage(for: nsURL) {
                thumbnailImageView.image = cachedImage
                thumbnailImageView.isHidden = false
                setImageConstraints(for: post)
            } else {
                thumbnailImageView.isHidden = true
                currentImageTask = imageDownloader.downloadImage(from: url) { [weak self] image in
                    guard let self = self, let image = image else { return }
                    ImageCache.shared.setImage(image, for: nsURL)
                    
                    DispatchQueue.main.async {
                        if self.currentImageURL == url {
                            self.thumbnailImageView.image = image
                            self.thumbnailImageView.isHidden = false
                            self.setImageConstraints(for: post)
                            self.updateCellLayout()
                        }
                    }
                }
            }
        } else {
            thumbnailImageView.isHidden = true
            imageHeightConstraint?.isActive = false
            aspectRatioConstraint?.isActive = false
        }
    }

    private func setImageConstraints(for post: RedditPost.Data) {
        guard let thumbnailWidth = post.thumbnail_width, let thumbnailHeight = post.thumbnail_height else {
            thumbnailImageView.isHidden = true
            return
        }

        let aspectRatio = CGFloat(thumbnailHeight) / CGFloat(thumbnailWidth)

        aspectRatioConstraint = thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: aspectRatio)
        aspectRatioConstraint?.isActive = true
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
