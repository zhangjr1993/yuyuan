import UIKit
import Hero

class StoryDetailController: BasicController {
    private let storyDetail: StoryModel
    private var isAnimating = false
    private var currentProgress: UserStoryProgress?
    
    var cellHeroId: String?
    var coverHeroId: String?
    var titleHeroId: String?
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(StoryInfoCell.self, forCellReuseIdentifier: StoryInfoCell.identifier)
        table.register(StoryStageCell.self, forCellReuseIdentifier: StoryStageCell.identifier)
        return table
    }()
    
    private lazy var headerView: StoryHeaderView = {
        let header = StoryHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        header.configure(with: storyDetail.cover)
        return header
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    init(storyDetail: StoryModel) {
        self.storyDetail = storyDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProgress()
        
        // Set navigation title
        title = storyDetail.name

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEnterButtonTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 添加视差滚动效果
        if let tableHeaderView = tableView.tableHeaderView as? StoryHeaderView {
            tableHeaderView.scrollViewDidScroll(tableView)
        }
    }
    
    // MARK: - UI Setup
    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(enterButton)
        view.addSubview(loadingImageView)
        
        tableView.tableHeaderView = headerView
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        loadingImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: enterButton.topAnchor, constant: -20),
            
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            enterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            enterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            enterButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingImageView.widthAnchor.constraint(equalToConstant: 100),
            loadingImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Progress Management
    private func loadUserProgress() {
        let userId = 1
        currentProgress = UserStoryProgressManager.shared.getProgress(userId: userId, storyId: storyDetail.mid)
    }
    
    private func updateEnterButtonTitle() {
        let title = currentProgress != nil ? "继续聊天" : "开启第一幕"
        enterButton.setTitle(title, for: .normal)
        tableView.reloadData()
    }
    
    private func saveUserProgress(actTitle: String) {
        let userId = 1
        let progress = UserStoryProgress(userId: userId, storyId: storyDetail.mid, currentActTitle: actTitle)
        UserStoryProgressManager.shared.saveProgress(progress)
        currentProgress = progress
    }
    
    // MARK: - Actions
    @objc private func enterButtonTapped() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // 显示动画
        loadingImageView.isHidden = false
        if let gifURL = Bundle.main.url(forResource: "openingStory", withExtension: "gif") {
            loadingImageView.kf.setImage(with: gifURL)
        }
        
        // 1秒后进入聊天页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isAnimating = false
            self?.loadingImageView.isHidden = true
            self?.enterChatRoom()
        }
    }
    
    private func enterChatRoom() {
        let actTitle: String
        if let progress = currentProgress {
            actTitle = progress.currentActTitle
        } else {
            actTitle = storyDetail.act.first?.title ?? ""
            saveUserProgress(actTitle: actTitle)
        }
        
        if let actModel = storyDetail.act.first(where: { $0.title == actTitle }) {
            /// json文件头像还没加，字段也要加headpic
            var chatModel = StoryChatInfoModel()
            chatModel.name = storyDetail.name
            chatModel.intro = storyDetail.intro
            chatModel.mid = storyDetail.mid
            chatModel.audioFile = storyDetail.audioFile
            chatModel.actInfo = actModel
            
            let chatVC = StoryChatController(chatInfoModel: chatModel)
            navigationController?.pushViewController(chatVC, animated: true)
        }
        
    }
}

// MARK: - UITableViewDelegate & DataSource
extension StoryDetailController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : storyDetail.act.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryInfoCell.identifier, for: indexPath) as! StoryInfoCell
            cell.configure(with: storyDetail)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryStageCell.identifier, for: indexPath) as! StoryStageCell
            let actModel = storyDetail.act[indexPath.row]
            let isInProgress = currentProgress?.currentActTitle == actModel.title
            cell.configure(with: actModel, isInProgress: isInProgress)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        let header = UIView()
        header.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "故事阶段"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        header.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        var actModel = storyDetail.act[indexPath.row]
        
        let tempArr = UserManager.shared.actIdArray
        actModel.isLock = tempArr.contains(actModel.actId)
        
        if !actModel.isLock && !UserManager.shared.isMembershipValid {
            let alert = UIAlertController(title: "温馨提示", message: "是否消耗\(actModel.coin)金币解锁故事？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                self.costFlowerLock(actModel)
            })
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                
            })
            present(alert, animated: true)
            
            return
        }
        
        self.startStoryChat(actModel)
    }
    
    private func startStoryChat(_ actModel: ActModel) {
        // 保存用户进度
        saveUserProgress(actTitle: actModel.title)
        currentProgress?.currentActTitle = actModel.title
        self.enterChatRoom()
    }
    
    private func costFlowerLock(_ model: ActModel) {
        if UserManager.shared.currentUser.coin - model.coin >= 0 {
            if !UserManager.shared.actIdArray.contains(model.actId) {
                var tempArr = UserManager.shared.actIdArray
                tempArr.append(model.actId)
                UserManager.shared.actIdArray = tempArr
            }
            var currentUser = UserManager.shared.currentUser
            currentUser.coin -= model.coin
            UserManager.shared.updateUser(coin: currentUser.coin)
            
            self.startStoryChat(model)
        }else {
            let alert = UIAlertController(title: "温馨提示", message: "余额不足，是否前往充值页面？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "前往", style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                let vc = MemberController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            present(alert, animated: true)
        }
    }
}
