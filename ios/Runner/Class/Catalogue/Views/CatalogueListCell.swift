//
//  CatalogueListCell.swift
//  Runner
//
//  Created by Bolo on 2025/3/17.
//

import UIKit

class CatalogueListCell: UITableViewCell {

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor.hexStr("#111111")
        return label
    }()
    
    private let profileLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor.hexStr("#666666")
        return label
    }()
    
    private let progressIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.layer.cornerRadius = 4
        view.isHidden = true
        return view
    }()
    
    private let lockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_jiasuo")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(profileLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(progressIndicator)
        contentView.addSubview(lockImageView)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            
            infoLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            infoLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            profileLabel.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
            profileLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 4),
            profileLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            lastMessageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            lastMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            lastMessageLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            lastMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            progressIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            progressIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            progressIndicator.widthAnchor.constraint(equalToConstant: 4),
            progressIndicator.heightAnchor.constraint(equalToConstant: 40),
            
            lockImageView.leadingAnchor.constraint(equalTo: infoLabel.trailingAnchor, constant: 8),
            lockImageView.centerYAnchor.constraint(equalTo: infoLabel.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 14),
            lockImageView.heightAnchor.constraint(equalToConstant: 14),

        ])
    }
    
    func configure(with model: ActModel, isInProgress: Bool = false) {
        avatarImageView.image = UIImage(named: model.aiRole.headpic)
        
        // Configure info label with name, age, and gender
        let infoText = "\(model.aiRole.name) \(model.aiRole.age)岁 \(model.aiRole.sex)"
        infoLabel.text = infoText
        
        // Configure profile
        profileLabel.text = model.aiRole.profile
        
        // Show progress indicator if this is the current act in progress
        progressIndicator.isHidden = !isInProgress
        
        // Add a subtle background color if in progress
        if isInProgress {
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        } else {
            contentView.backgroundColor = .white
        }
        
        let tempArr = UserManager.shared.actIdArray
        lockImageView.isHidden = model.isLock || tempArr.contains(model.actId)
    }
}
