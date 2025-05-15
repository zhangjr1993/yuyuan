import UIKit

class UserCenterHeaderView: UIView {
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.image = UIImage(named: "default_avatar")
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.text = "未设置昵称"
        return label
    }()
    
    private let editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_bianji")
        return imageView
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(avatarImageView)
        addSubview(nicknameLabel)
        addSubview(editImageView)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        editImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nicknameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nicknameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nicknameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            editImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 0),
            editImageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: -15),
            editImageView.widthAnchor.constraint(equalToConstant: 20),
            editImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func configure(avatar: UIImage?, nickname: String?) {
        if let avatar = avatar {
            avatarImageView.image = avatar
        }
        nicknameLabel.text = nickname ?? "未设置昵称"
    }
} 
