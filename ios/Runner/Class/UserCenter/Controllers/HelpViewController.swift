import UIKit

class HelpViewController: BasicController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let sections = [
        ("广场", "在广场上，你将邂逅丰富多彩的原创故事模板，它们如同一扇扇通往奇幻世界的门扉。每一种模板都蕴含着独特的魅力，或惊险刺激，或温馨动人，或奇幻瑰丽。只需轻轻一点，你便能踏入详情页，与智能AI携手，共同开启一场精彩绝伦的角色演绎之旅。在这里，你可以尽情释放想象力，为角色注入灵魂，让他们的故事在你的笔下绽放光彩，书写出属于你自己的传奇篇章，感受人生的千姿百态。"),
        ("回目", "回目，宛如一座故事的宝库，将所有的故事线毫无保留地展现在你眼前。你可以像欣赏一幅精美的画卷一样，一目了然地浏览这些错综复杂却又引人入胜的故事脉络。无论是热血沸腾的英雄史诗，还是细腻入微的情感故事，亦或是充满奇幻色彩的冒险之旅，你都能轻松找到自己心仪的那一款。挑选出你最爱的场景，与AI展开深度互动，仿佛置身于故事之中，与角色们并肩作战，共同面对挑战，体验每一个精彩瞬间，感受故事的魅力与力量。"),
        ("时空长廊", "现在，就让我们一同踏入这条神秘的时空长廊，开启一场不同寻常的奇妙之旅。在这里，你可以穿梭于不同的时空，模拟出各种各样的人生轨迹。从古代的宫廷权谋到现代的都市奋斗，从未来的星际探险到奇幻世界的魔法冒险，每一段人生都充满了起起落落，充满了未知与惊喜。你会经历成功的喜悦，也会遭遇失败的挫折；会品尝爱情的甜蜜，也会感受友情的温暖；会面临艰难的选择，也会收获意外的惊喜。通过这些模拟人生，你将深刻地体会到人生的百味，收获宝贵的人生感悟，开启一场心灵的探索之旅。")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "使用帮助"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HelpCell.self, forCellReuseIdentifier: "HelpCell")
    }
}

extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath) as! HelpCell
        let (title, content) = sections[indexPath.section]
        cell.configure(title: title, content: content)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
}

class HelpCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
} 
