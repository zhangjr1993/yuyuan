import UIKit

class UserCenterController: BasicController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(UserCenterItemCell.self, forCellReuseIdentifier: UserCenterItemCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tableView
    }()
    
    private let headerView: UserCenterHeaderView = {
        let header = UserCenterHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220))
        header.layer.cornerRadius = 16
        header.clipsToBounds = true
        return header
    }()
    
    private let sections: [[String: Any]] = [
        ["title": "账号安全", "items": [
            ["title": "用户协议", "icon": "doc.text.fill"],
            ["title": "隐私协议", "icon": "lock.shield.fill"],
        ]],
        ["title": "帮助与反馈", "items": [
            ["title": "使用帮助", "icon": "questionmark.circle.fill"],
            ["title": "意见反馈", "icon": "message.fill"],
        ]],
        ["title": "其他", "items": [
            ["title": "关于我们", "icon": "info.circle.fill"],
            ["title": "关于APP", "icon": "app.badge.fill"],
            ["title": "退出登录", "icon": "gearshape.fill"],
        ]]
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        var image: UIImage?
        if let imgData = Data(base64Encoded: UserManager.shared.currentUser.avatar, options: .ignoreUnknownCharacters) {
            image = UIImage(data: imgData)
        }

        headerView.configure(avatar: image, nickname: UserManager.shared.currentUser.nickname)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func setupUI() {
        super.setupUI()
        self.hideNavigation = true
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped))
        headerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func editButtonTapped() {
        // TODO: 跳转到编辑用户信息页面
        let editProfileVC = EditProfileController()
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc private func headerViewTapped() {
        // 点击头像区域也可以跳转到编辑页面
        editButtonTapped()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension UserCenterController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = sections[section]["items"] as? [[String: String]] {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]["title"] as? String
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = sections[section]["title"] as? String
        
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCenterItemCell.identifier, for: indexPath) as! UserCenterItemCell
        
        if let items = sections[indexPath.section]["items"] as? [[String: String]],
           let title = items[indexPath.row]["title"],
           let iconName = items[indexPath.row]["icon"] {
            let icon = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
            cell.configure(icon: icon, title: title)
        }
        
        // 设置cell的圆角
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        // 根据位置设置圆角
        if let rowCount = sections[indexPath.section]["items"] as? [[String: String]] {
            if rowCount.count == 1 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else if indexPath.row == 0 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == rowCount.count - 1 {
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.maskedCorners = []
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let items = sections[indexPath.section]["items"] as? [[String: String]],
           let title = items[indexPath.row]["title"] {
            switch title {
            case "用户协议":
                let userAgreementURL = "https://sites.google.com/view/roleplayuser"
                let webVC = WebViewController(url: userAgreementURL, title: "用户协议")
                navigationController?.pushViewController(webVC, animated: true)
            case "隐私协议":
                let privacyPolicyURL = "https://sites.google.com/view/roleplayprivacy"
                let webVC = WebViewController(url: privacyPolicyURL, title: "隐私协议")
                navigationController?.pushViewController(webVC, animated: true)
            case "使用帮助":
                let helpVC = HelpViewController()
                navigationController?.pushViewController(helpVC, animated: true)
            case "意见反馈":
                let feedbackVC = FeedbackViewController()
                navigationController?.pushViewController(feedbackVC, animated: true)
            case "关于我们":
                let aboutUsVC = AboutUsViewController()
                navigationController?.pushViewController(aboutUsVC, animated: true)
            case "关于APP":
                let aboutAppVC = AboutAppViewController()
                navigationController?.pushViewController(aboutAppVC, animated: true)
            case "退出登录":
                let alert = UIAlertController(title: "退出登录", message: "确定要退出登录吗？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                alert.addAction(UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
                    // 清除用户登录状态
                    UserManager.shared.logout()
                    
                    // 切换到登录界面
                    if let window = UIApplication.shared.windows.first {
                        let loginVC = LoginViewController()
                        window.rootViewController = loginVC
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                    }
                })
                present(alert, animated: true)
            default:
                break
            }
        }
    }
}


