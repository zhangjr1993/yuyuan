import UIKit
import MJRefresh
import AVFoundation

// MARK: - Message Type
enum MessageType {
    case normal
    case tip
}

extension MessageModel {
    var type: MessageType {
        // 如果发送者名称为空，则认为是 tip 类型
        return senderName.isEmpty ? .tip : .normal
    }
}

class StoryChatController: BasicController {
    
    private var chatModel: StoryChatInfoModel
    private var actTitle: String
    private var messages: [MessageModel] = []
    private let aiService: AIService
    private var currentPage: Int = 0
    private var isLoadingMore: Bool = false
    private var hasInsertedTip = false
    private var audioPlayer: AVAudioPlayer?

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        table.register(ChatBubbleCell.self, forCellReuseIdentifier: "ChatBubbleCell")
        table.register(TipBubbleCell.self, forCellReuseIdentifier: "TipBubbleCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        table.keyboardDismissMode = .onDrag // 滑动时收起键盘
        return table
    }()
    
    private lazy var chatInputView: ChatInputView = {
        let view = ChatInputView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(chatInfoModel: StoryChatInfoModel) {
        self.chatModel = chatInfoModel
        self.actTitle = chatModel.name
        self.aiService = AIService(apiKey: "ccfb7e6d7e9f4008b7a8446cfa2bb053.XBUInuKVafKfrzpD")
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupTapGesture()
        loadInitialMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBackgroundMusic()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBackgroundMusic()
    }
    
    override func setupUI() {
        super.setupUI()
        title = actTitle
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(chatInputView)
        view.addSubview(loadingView)
        
        if #available(iOS 15.0, *) {
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                chatInputView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
                chatInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                chatInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                chatInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
                
                loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingView.bottomAnchor.constraint(equalTo: chatInputView.topAnchor, constant: -8)
            ])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                chatInputView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
                chatInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                chatInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                chatInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                
                loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingView.bottomAnchor.constraint(equalTo: chatInputView.topAnchor, constant: -8)
            ])
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // 添加下拉刷新
        let header = MJRefreshNormalHeader { [weak self] in
            self?.loadMoreMessages()
        }
        header?.lastUpdatedTimeLabel?.isHidden = true
        header?.stateLabel?.isHidden = true
        tableView.mj_header = header
    }
    
    private func setupTapGesture() {
        // 添加点击手势来收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 允许点击事件继续传递
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func loadInitialMessages() {
        // 加载最新的消息
        let cachedMessages = ChatDatabaseManager.shared.getMessages(
            mid: chatModel.mid.description,
            actId: chatModel.actInfo.actId.description,
            uid: UserManager.shared.currentUser.uid,
            page: 0
        )
        
        if cachedMessages.isEmpty {
            // 第一次进入，使用动画插入提示
            insertStoryTip(isFirstTime: true)
        } else {
            // 按时间升序排列消息
            messages = cachedMessages.sorted { $0.timestamp < $1.timestamp }
            tableView.reloadData()
            scrollToBottom(animated: false)
            
            // 如果消息数量小于20，说明是最后一页，插入提示（无动画）
            if cachedMessages.count < 20 {
                insertStoryTip(isFirstTime: false)
            }
        }
    }
    
    private func loadMoreMessages() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        currentPage += 1
        let olderMessages = ChatDatabaseManager.shared.getMessages(
            mid: chatModel.mid.description,
            actId: chatModel.actInfo.actId.description,
            uid: UserManager.shared.currentUser.uid,
            page: currentPage
        )
        
        if olderMessages.isEmpty && !hasInsertedTip {
            // 没有更多历史消息了，插入提示（无动画）
            insertStoryTip(isFirstTime: false)
        } else if !olderMessages.isEmpty {
            // 将新消息按时间升序排列后插入到现有消息前面
            let sortedMessages = olderMessages.sorted { $0.timestamp < $1.timestamp }
            messages.insert(contentsOf: sortedMessages, at: 0)
            tableView.reloadData()
        }
        
        isLoadingMore = false
        tableView.mj_header?.endRefreshing()
    }
    
    private func addMessage(_ message: MessageModel) {
        // 由于新消息总是最新的，直接添加到末尾即可
        messages.append(message)
        
        // 保存消息到数据库
        ChatDatabaseManager.shared.saveMessage(
            message,
            mid: chatModel.mid.description,
            actId: chatModel.actInfo.actId.description,
            uid: UserManager.shared.currentUser.uid
        )
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        scrollToBottom(animated: true)
    }
    
    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let lastIndex = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: animated)
    }
    
    private func startLoading() {
        loadingView.startAnimating()
        chatInputView.setEnabled(false)
    }
    
    private func stopLoading() {
        loadingView.stopAnimating()
        chatInputView.setEnabled(true)
    }
    
    private func insertStoryTip(isFirstTime: Bool) {
        guard !hasInsertedTip else { return }
        hasInsertedTip = true
        
        // 创建开场白介绍消息，设置较早的时间戳确保显示在最前面
        let openMessage = MessageModel(
            content: "\(chatModel.name)\n\(chatModel.intro)",
            isUser: false,
            senderName: "", // 空的发送者名称表示这是一个 tip 类型消息
            senderAvatar: "",
            timestamp: Date().addingTimeInterval(-86400) // 设置为24小时前
        )
        
        // 创建背景介绍消息
        let introMessage = MessageModel(
            content: "\(chatModel.actInfo.title)\n\(chatModel.actInfo.desc)\n\(chatModel.actInfo.playRole.profile)",
            isUser: false,
            senderName: "",
            senderAvatar: "",
            timestamp: Date().addingTimeInterval(-86399) // 设置为比开场白晚1秒
        )
        
        if isFirstTime {
            // 首次进入时，使用动画效果
            tableView.beginUpdates()
            
            // 先插入数据
            messages.insert(contentsOf: [openMessage, introMessage], at: 0)
            
            // 创建要插入的 indexPaths
            let indexPaths = [
                IndexPath(row: 0, section: 0),
                IndexPath(row: 1, section: 0)
            ]
            
            // 插入行
            tableView.insertRows(at: indexPaths, with: .none)
            tableView.endUpdates()
            
            // 获取插入的cells并添加淡入动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                let cells = indexPaths.compactMap { self.tableView.cellForRow(at: $0) }
                
                // 初始设置cells为透明
                cells.forEach { $0.alpha = 0 }
                
                // 延迟0.5秒后开始动画
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.animate(withDuration: 0.75) {
                        cells.forEach { $0.alpha = 1 }
                    }
                }
            }
        } else {
            // 非首次进入，直接插入无动画
            tableView.beginUpdates()
            messages.insert(contentsOf: [openMessage, introMessage], at: 0)
            let indexPaths = [
                IndexPath(row: 0, section: 0),
                IndexPath(row: 1, section: 0)
            ]
            tableView.insertRows(at: indexPaths, with: .none)
            tableView.endUpdates()
        }
    }
    
    private func setupBackgroundMusic() {
        guard let audioPath = Bundle.main.path(forResource: chatModel.audioFile, ofType: "mp3") else {
            return
        }
        
        // 配置音频会话以支持后台播放
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer?.numberOfLoops = -1 // 无限循环播放
            audioPlayer?.prepareToPlay()
            
            // Delay 6 seconds before playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
                self?.audioPlayer?.play()
            }
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }
    }
    
    private func stopBackgroundMusic() {
        // 先淡出音量
        audioPlayer?.volume = 0.5
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.audioPlayer?.volume = 0
        } completion: { [weak self] _ in
            // 音量淡出后再停止和释放
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension StoryChatController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        switch message.type {
        case .tip:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TipBubbleCell", for: indexPath) as! TipBubbleCell
            let components = message.content.components(separatedBy: "\n")
            let title = components.first ?? ""
            let content = components.dropFirst().joined(separator: "\n")
            cell.configure(title: title, content: content)
            return cell
            
        case .normal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBubbleCell", for: indexPath) as! ChatBubbleCell
            cell.configure(with: message)
            return cell
        }
    }
}

// MARK: - ChatInputViewDelegate
extension StoryChatController: ChatInputViewDelegate {
    func chatInputView(_ inputView: ChatInputView, didSendMessage message: String) {
        // 添加用户消息
        let userMessage = MessageModel(
            content: message,
            isUser: true,
            senderName: "我",
            senderAvatar: "" // 设置用户头像URL
        )
        addMessage(userMessage)
        
        // 开始加载动画
        startLoading()
        
        // 发送消息给AI
        let roleSettings = """
        你现在扮演的角色设定如下：
        \(chatModel.actInfo.aiRole.name)，年龄：\(chatModel.actInfo.aiRole.age)，\(chatModel.actInfo.aiRole.profile)
        背景设定：
        \(chatModel.name )，\(chatModel.intro)，\(chatModel.actInfo.background)
        和你对话的是：
        \(chatModel.actInfo.playRole.name)，年龄：\(chatModel.actInfo.playRole.age)，\(chatModel.actInfo.playRole.profile)
        请始终保持角色设定进行对话。
        """
        
        aiService.sendMessage(message, roleSettings: roleSettings) { [weak self] result in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.stopLoading()
                
                switch result {
                case .success(let response):
                    self.addReplyMsg(response)
                case .failure(let error):
                    // 显示错误提示
                    let alert = UIAlertController(
                        title: "错误",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func addReplyMsg(_ content: String) {
        let actInfo = self.chatModel.actInfo
        
        // 添加AI回复消息
        let aiMessage = MessageModel(
            content: content,
            isUser: false,
            senderName: actInfo.aiRole.name,
            senderAvatar: actInfo.aiRole.headpic
        )
        self.addMessage(aiMessage)
    }
}

// MARK: - TipBubbleCell
class TipBubbleCell: UITableViewCell {
    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1) // #111111
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1) // #555555
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(titleLabel)
        bubbleView.addSubview(contentLabel)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width - 24.0),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            contentLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
        
        // 强制布局以确保气泡大小正确
        layoutIfNeeded()
    }
}

// MARK: - ChatBubbleCell
class ChatBubbleCell: UITableViewCell {
    private let bubbleView = ChatBubbleView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(bubbleView)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with message: MessageModel) {
        bubbleView.configure(with: message)
    }
}
