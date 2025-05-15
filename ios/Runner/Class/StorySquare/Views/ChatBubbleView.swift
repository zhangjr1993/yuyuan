import UIKit

class ChatBubbleView: UIView {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray5 // 默认背景色
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var userConstraints: [NSLayoutConstraint] = []
    private var aiConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        // 头像固定宽高
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        // 消息文本内容约束
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 240)
        ])
        
        // 用户消息的约束
        userConstraints = [
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            nameLabel.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            
            bubbleView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        // AI消息的约束
        aiConstraints = [
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            
            bubbleView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
    }
    
    func configure(with message: MessageModel) {
        messageLabel.text = message.content
        nameLabel.text = message.senderName
        
        // 设置头像
        avatarImageView.image = UIImage(named: message.senderAvatar)

        
        // 根据消息类型设置样式和约束
        if message.isUser {
            // 停用AI约束，启用用户约束
            NSLayoutConstraint.deactivate(aiConstraints)
            NSLayoutConstraint.activate(userConstraints)
            
            // 设置用户消息样式
            bubbleView.backgroundColor = UIColor.hexStr("64A8F8")
            messageLabel.textColor = .white
            nameLabel.textColor = UIColor.hexStr("FFD700") // 金色
            nameLabel.textAlignment = .right
        } else {
            // 停用用户约束，启用AI约束
            NSLayoutConstraint.deactivate(userConstraints)
            NSLayoutConstraint.activate(aiConstraints)
            
            // 设置AI消息样式
            bubbleView.backgroundColor = .hexStr("EC6A65")
            messageLabel.textColor = .white
            nameLabel.textColor = .black
            nameLabel.textAlignment = .left
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
