//
//  CatalogueHeaderView.swift
//  Runner
//
//  Created by Bolo on 2025/3/17.
//

import UIKit

class CatalogueHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    var section: Int?
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.hexStr("#666666")
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        imageView.image = UIImage(systemName: "chevron.up", withConfiguration: config)
        return imageView
    }()
    
    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = UIColor.hexStr("#F6F8FF")
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 69),
            avatarImageView.heightAnchor.constraint(equalToConstant: 69),
            
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -10),
            
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Configuration
    func configure(with model: StoryModel?) {
        guard let model = model else { return }
       
        avatarImageView.image = UIImage(named: model.cover)
        titleLabel.text = model.name
    }
    
    func updateArrowDirection(_ isExpanded: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let imageName = isExpanded ? "chevron.up" : "chevron.down"
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.image = UIImage(systemName: imageName, withConfiguration: config)
        }
    }
}
