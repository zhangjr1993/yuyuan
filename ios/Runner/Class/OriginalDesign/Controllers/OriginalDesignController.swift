import UIKit
import AVFoundation

class OriginalDesignController: BasicController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var typewriterLabel: UILabel?
    private var typewriterTimer: Timer?
    private var currentTextIndex = 0
    private var backgroundText: String = ""
    private var currentModel: TimeTravelModel?
    
    // 添加星空背景
    private var starfieldView: UIView?
    private var stars: [CALayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNavigation = true
        setupStarfield()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.starfieldView?.alpha = 1
    }
    
    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .black
        
        // 创建时空隧道效果
        let tunnelView = UIView()
        tunnelView.backgroundColor = .clear
        view.addSubview(tunnelView)
        
        // 创建渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        tunnelView.layer.addSublayer(gradientLayer)
        
        // 创建时空隧道动画
        let tunnelAnimation = CABasicAnimation(keyPath: "transform.scale")
        tunnelAnimation.fromValue = 1.0
        tunnelAnimation.toValue = 1.2
        tunnelAnimation.duration = 2.0
        tunnelAnimation.autoreverses = true
        tunnelAnimation.repeatCount = .infinity
        tunnelView.layer.add(tunnelAnimation, forKey: "tunnelAnimation")
        
        // 创建底部按钮
        let button = UIButton(type: .system)
        button.setTitle("开启时空穿梭", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        // 创建按钮渐变背景
        let buttonGradient = CAGradientLayer()
        buttonGradient.colors = [
            UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.1, blue: 0.4, alpha: 1.0).cgColor
        ]
        buttonGradient.locations = [0.0, 1.0]
        buttonGradient.startPoint = CGPoint(x: 0, y: 0)
        buttonGradient.endPoint = CGPoint(x: 1, y: 1)
        button.layer.insertSublayer(buttonGradient, at: 0)
        
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0).cgColor
        
        // 添加按钮发光效果
        button.layer.shadowColor = UIColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 0.5).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.5
        
        button.addTarget(self, action: #selector(readyForTimeTravel), for: .touchUpInside)
        view.addSubview(button)
        
        // 设置约束
        tunnelView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tunnelView.topAnchor.constraint(equalTo: view.topAnchor),
            tunnelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tunnelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tunnelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 更新按钮渐变层frame
        buttonGradient.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
    }
    
    private func setupStarfield() {
        starfieldView = UIView(frame: view.bounds)
        starfieldView?.backgroundColor = .clear
        if let starfieldView = starfieldView {
            view.insertSubview(starfieldView, at: 0)
            
            // 创建星星
            for _ in 0..<100 {
                let star = CALayer()
                star.backgroundColor = UIColor.white.cgColor
                star.cornerRadius = 1
                star.opacity = Float.random(in: 0.2...0.8)
                
                let size = CGFloat.random(in: 1...3)
                star.frame = CGRect(
                    x: CGFloat.random(in: 0...view.bounds.width),
                    y: CGFloat.random(in: 0...view.bounds.height),
                    width: size,
                    height: size
                )
                
                starfieldView.layer.addSublayer(star)
                stars.append(star)
                
                // 添加星星闪烁动画
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = star.opacity
                animation.toValue = Float.random(in: 0.2...0.8)
                animation.duration = Double.random(in: 1...3)
                animation.autoreverses = true
                animation.repeatCount = .infinity
                star.add(animation, forKey: "twinkle")
            }
        }
    }
    
    @objc private func readyForTimeTravel() {
        guard let listModel = TimeTravelListModel.loadTravelInfo() else {
            return
        }
        
        // 随机选择一个模式
        let randomIndex = Int.random(in: 0..<listModel.list.count)
        currentModel = listModel.list[randomIndex]
        backgroundText = currentModel?.backgroud ?? ""
        
        // 先跳转到 TimeTravelController
        if let model = currentModel {
            let timeTravelVC = TimeTravelController()
            timeTravelVC.model = model
            navigationController?.pushViewController(timeTravelVC, animated: false)
        }
        
        // 播放视频
        if let videoURL = Bundle.main.url(forResource: "shikong_travel", withExtension: "mp4") {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            
            // 获取window并添加视频层
            if let window = UIApplication.shared.windows.first {
                playerLayer?.frame = window.bounds
                playerLayer?.videoGravity = .resizeAspectFill
                window.layer.addSublayer(playerLayer!)
                
                // 添加视频播放完成的观察者
                NotificationCenter.default.addObserver(self,
                                                     selector: #selector(playerDidFinishPlaying),
                                                     name: .AVPlayerItemDidPlayToEndTime,
                                                     object: player?.currentItem)
                
                // 开始播放视频
                player?.play()
                
                // 创建打字机效果的标签
                setupTypewriterLabel()
                
                // 添加视频播放时的过渡效果
                UIView.animate(withDuration: 1.0) {
                    self.starfieldView?.alpha = 0
                }
            }
        }
    }
    
    private func setupTypewriterLabel() {
        // 创建背景容器视图
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        
        // 创建文本标签
        typewriterLabel = UILabel()
        typewriterLabel?.numberOfLines = 0
        typewriterLabel?.textColor = .white
        typewriterLabel?.font = .systemFont(ofSize: 16)
        typewriterLabel?.textAlignment = .left
        
        if let label = typewriterLabel, let window = UIApplication.shared.windows.first {
            // 添加视图到window
            window.addSubview(containerView)
            containerView.addSubview(label)
            
            // 设置约束
            containerView.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 32),
                containerView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -32),
                containerView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 32),
                
                // 标签约束，与容器保持8点的间距
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
            ])
            
            // 计算文本高度
            let maxWidth = window.bounds.width - 80 // 考虑左右边距(32*2)和内部间距(8*2)
            let textHeight = backgroundText.boundingRect(
                with: CGSize(width: maxWidth, height: CGFLOAT_MAX),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: label.font!],
                context: nil
            ).height + 2
            
            // 设置容器高度约束
            // 总高度 = 文本高度 + 上下内边距(8*2)
            containerView.heightAnchor.constraint(equalToConstant: textHeight+16).isActive = true
            
            // 添加淡入动画
            containerView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                containerView.alpha = 1
            }
            
            // 开始打字机效果
            startTypewriterEffect()
        }
    }
    
    private func startTypewriterEffect() {
        currentTextIndex = 0
        typewriterTimer?.invalidate()
        
        // 计算每行字符数
        let maxWidth = view.bounds.width - 80
        let charWidth = "字".size(withAttributes: [.font: typewriterLabel?.font ?? .systemFont(ofSize: 16)]).width
        let charsPerLine = Int(maxWidth / charWidth)
        
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentTextIndex < self.backgroundText.count {
                let index = self.backgroundText.index(self.backgroundText.startIndex, offsetBy: self.currentTextIndex)
                let currentText = String(self.backgroundText[self.backgroundText.startIndex...index])
                
                // 处理换行
                var formattedText = ""
                var currentLine = ""
                for char in currentText {
                    currentLine.append(char)
                }
                formattedText += currentLine
                
                self.typewriterLabel?.text = formattedText
                self.currentTextIndex += 1
            } else {
                self.typewriterTimer?.invalidate()
            }
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        // 添加渐隐动画
        UIView.animate(withDuration: 0.5, animations: {
            self.playerLayer?.opacity = 0
            self.typewriterLabel?.superview?.alpha = 0 // 修改为淡出整个容器视图
        }) { _ in
            // 动画完成后清理资源
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
            self.player = nil
            self.typewriterLabel?.superview?.removeFromSuperview() // 移除整个容器视图
            self.typewriterLabel = nil
        }
    }
    
    deinit {
        typewriterTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// 为 UILabel 添加内边距
extension UILabel {
    var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets.zero
        }
        set {
            let paddingView = UIView()
            paddingView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(paddingView)
            
            NSLayoutConstraint.activate([
                paddingView.topAnchor.constraint(equalTo: self.topAnchor),
                paddingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                paddingView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                paddingView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
            
            self.text = self.text
        }
    }
}
