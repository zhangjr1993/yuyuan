import UIKit

class StoryStageCell: UITableViewCell {
    static let identifier = "StoryStageCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let lockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_jiasuo")
        return imageView
    }()
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_flower")
        return imageView
    }()
    
    private let coinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.hexStr("#7E89A5")
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(lockImageView)
        containerView.addSubview(coinImageView)
        containerView.addSubview(coinLabel)
        containerView.addSubview(statusIndicator)
        containerView.addSubview(chevronImageView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        coinLabel.translatesAutoresizingMaskIntoConstraints = false
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 12),
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            coinLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            coinLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            coinLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            coinLabel.heightAnchor.constraint(equalToConstant: 14),

            coinImageView.leadingAnchor.constraint(equalTo: coinLabel.trailingAnchor, constant: 4),
            coinImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            coinImageView.widthAnchor.constraint(equalToConstant: 18),
            coinImageView.heightAnchor.constraint(equalToConstant: 18),

            lockImageView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            lockImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 14),
            lockImageView.heightAnchor.constraint(equalToConstant: 14),
                        
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 13),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with stage: ActModel, isInProgress: Bool = false) {
        titleLabel.text = stage.title
        statusIndicator.backgroundColor = isInProgress ? .systemGreen : .systemGray3
        coinLabel.text = "\(stage.coin)"
        
        let tempArr = UserManager.shared.actIdArray
        coinLabel.isHidden = stage.isLock || tempArr.contains(stage.actId)
        coinImageView.isHidden = stage.isLock || tempArr.contains(stage.actId)
        lockImageView.isHidden = stage.isLock || tempArr.contains(stage.actId)
    }
} 
