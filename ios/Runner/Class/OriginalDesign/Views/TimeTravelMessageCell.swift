//
//  TimeTravelMessageCell.swift
//  Runner
//
//  Created by Bolo on 2025/3/27.
//

import UIKit

// 定义消息类型
enum TravelMessageType {
    case title(String)      // 事件标题
    case option(String, Int) // 选项内容和tag
    case narration(String)  // 旁白内容
}

// 定义消息模型
struct TravelMessageModel {
    let type: TravelMessageType
    let alignment: BubbleView.BubbleAlignment
}

class TimeTravelMessageCell: UITableViewCell {

    private var bubbleView: BubbleView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: TravelMessageModel) {
        // 移除旧的气泡视图
        bubbleView?.removeFromSuperview()
        
        // 根据消息类型创建文本
        let text: String
        switch message.type {
        case .title(let title):
            text = title
        case .option(let option, let tag):
            switch tag {
            case 0: text = "A：" + option
            case 1: text = "B：" + option
            case 2: text = "C：" + option
            default: text = option
            }
        case .narration(let narration):
            text = narration
        }
        
        // 创建新的气泡视图
        bubbleView = BubbleView(text: text, alignment: message.alignment)
        if let bubbleView = bubbleView {
            contentView.addSubview(bubbleView)
            bubbleView.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalPadding: CGFloat = 24
            NSLayoutConstraint.activate([
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
            ])
            
            switch message.alignment {
            case .left:
                NSLayoutConstraint.activate([
                    bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
                    bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -horizontalPadding)
                ])
                
                // 如果是选项，设置勾选图片的约束
                if case .option = message.type {
                    bubbleView.checkImgView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        bubbleView.checkImgView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                        bubbleView.checkImgView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
                        bubbleView.checkImgView.widthAnchor.constraint(equalToConstant: 20),
                        bubbleView.checkImgView.heightAnchor.constraint(equalToConstant: 20)
                    ])
                }
                
            case .center, .right:
                NSLayoutConstraint.activate([
                    bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
                    bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
                ])
           
            }
        }
    }
    
    func updateSelected(_ selected: Bool) {
        guard case .left = bubbleView?.styleType else { return }
        if selected {
            bubbleView?.layer.borderWidth = 1
            bubbleView?.checkImgView.isHidden = false
        } else {
            bubbleView?.layer.borderWidth = 0
            bubbleView?.checkImgView.isHidden = true
        }
    }
}

class BubbleView: UIView {
    
    var styleType: BubbleAlignment = .left
    
    enum BubbleAlignment {
        case left
        case center
        case right
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let checkImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.image = UIImage(named: "gouxuan")
        return imageView
    }()
    
    init(text: String, alignment: BubbleAlignment) {
        super.init(frame: .zero)
        self.styleType = alignment
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius = 12
        layer.borderColor = UIColor.hexStr("#5FCD71").cgColor
        clipsToBounds = true
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding)
        ])
        
        switch alignment {
        case .left:
            label.textAlignment = .left
            addSubview(checkImgView)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
                label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -horizontalPadding)
            ])
            
        case .center, .right:
            label.textAlignment = .center
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
            ])
       
        }
        
        label.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
