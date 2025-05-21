import UIKit

class CatalogueController: BasicController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private var groupedData: [Int: [ActModel]] = [:]
    private var storyModels: [StoryModel] = []
    private var sectionKeys: [Int] = []
    private var listModel = StoryList.loadFromFile()
    private var collapsedSections: Set<Int> = [] // Track collapsed sections
    private var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNavigation = true
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 刷新表格以更新进度状态
        tableView.reloadData()
    }
    
    override func setupUI() {
        super.setupUI()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.text = "故事线"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(CatalogueHeaderView.self, forHeaderFooterViewReuseIdentifier: CatalogueHeaderView.description())
        tableView.register(CatalogueListCell.self, forCellReuseIdentifier: CatalogueListCell.description())
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // tableView constraints
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupData() {
        // Group data by StoryModel.mid
        if let dataModel = listModel {
            storyModels.append(contentsOf: dataModel.movies)
            storyModels.append(contentsOf: dataModel.novel)
            storyModels.append(contentsOf: dataModel.drama)
            
            for story in storyModels {
                sectionKeys.append(story.mid)
                groupedData[story.mid] = story.act
            }
        }
    }
    
    // MARK: - Actions
    @objc private func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let headerView = gesture.view as? CatalogueHeaderView,
              let section = headerView.section else { return }
        
        if collapsedSections.contains(section) {
            collapsedSections.remove(section)
        } else {
            collapsedSections.insert(section)
        }
        
        // Update arrow direction
        headerView.updateArrowDirection(!collapsedSections.contains(section))
        
        // Animate section collapse/expand
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    // MARK: - User Progress Management
    private func saveUserProgress(storyId: Int, actTitle: String) {
        let userId = 1 // 假设当前用户ID为1，实际应用中应该从用户管理获取
        let progress = UserStoryProgress(userId: userId, storyId: storyId, currentActTitle: actTitle)
        UserStoryProgressManager.shared.saveProgress(progress)
    }
    
    // MARK: - Navigation
    private func navigateToChat(storyModel: StoryModel, actModel: ActModel) {
        // 保存用户进度
        saveUserProgress(storyId: storyModel.mid, actTitle: actModel.title)
        
        // 创建聊天信息模型
        var chatModel = StoryChatInfoModel()
        chatModel.name = storyModel.name
        chatModel.intro = storyModel.intro
        chatModel.mid = storyModel.mid
        chatModel.audioFile = storyModel.audioFile
        chatModel.actInfo = actModel
        
        // 创建并跳转到聊天控制器
        let chatVC = StoryChatController(chatInfoModel: chatModel)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CatalogueController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionKeys[section]
        return collapsedSections.contains(section) ? 0 : (groupedData[key]?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CatalogueHeaderView.description()) as! CatalogueHeaderView
        let storyModel = storyModels.first { $0.mid == sectionKeys[section] }
        headerView.section = section
        headerView.configure(with: storyModel)
        headerView.updateArrowDirection(!collapsedSections.contains(section))
        
        // Add tap gesture if not already added
        if headerView.gestureRecognizers?.isEmpty ?? true {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
            headerView.addGestureRecognizer(tapGesture)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CatalogueListCell.description(), for: indexPath) as! CatalogueListCell
        let key = sectionKeys[indexPath.section]
        if let acts = groupedData[key], indexPath.row < acts.count {
            let actModel = acts[indexPath.row]
            
            // 获取当前故事ID
            let storyId = sectionKeys[indexPath.section]
            
            // 检查是否有进度记录
            let userId = 1 // 假设当前用户ID为1
            let progress = UserStoryProgressManager.shared.getProgress(userId: userId, storyId: storyId)
            let isInProgress = progress?.currentActTitle == actModel.title
            
            cell.configure(with: actModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 获取选中的故事ID和剧情模型
        let storyId = sectionKeys[indexPath.section]
        guard let storyModel = storyModels.first(where: { $0.mid == storyId }),
              let acts = groupedData[storyId],
              indexPath.row < acts.count else {
            return
        }
        
        var actModel = acts[indexPath.row]
        let tempArr = UserManager.shared.actIdArray
        actModel.isLock = tempArr.contains(actModel.actId)
        
        if !actModel.isLock && !UserManager.shared.isMembershipValid {
            let alert = UIAlertController(title: "温馨提示", message: "是否消耗\(actModel.coin)金币解锁故事？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                self.costFlower(storyModel, actModel)
            })
            present(alert, animated: true)
            
            return
        }
        
        // 导航到聊天界面
        navigateToChat(storyModel: storyModel, actModel: actModel)
    }
    
    private func costFlower(_ storyModel: StoryModel, _ model: ActModel) {
        if UserManager.shared.currentUser.coin - model.coin >= 0  {
            if !UserManager.shared.actIdArray.contains(model.actId) {
                var tempArr = UserManager.shared.actIdArray
                tempArr.append(model.actId)
                UserManager.shared.actIdArray = tempArr
            }
            var currentUser = UserManager.shared.currentUser
            currentUser.coin -= model.coin
            UserManager.shared.updateUser(coin: currentUser.coin)
            
            tableView.reloadData()
            navigateToChat(storyModel: storyModel, actModel: model)
        }else {
            let alert = UIAlertController(title: "温馨提示", message: "余额不足，是否前往充值页面？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "前往", style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                let vc = MemberController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                
            })
            present(alert, animated: true)
        }
    }
}

