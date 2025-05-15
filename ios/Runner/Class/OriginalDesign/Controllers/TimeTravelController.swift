//
//  TimeTravelController.swift
//  Runner
//
//  Created by Bolo on 2025/3/26.
//

import UIKit
import AVFoundation
import QuartzCore

// 添加礼花粒子视图类
class FireworksView: UIView {
    private var displayLink: CADisplayLink?
    private var particles: [Particle] = []
    private var colors: [UIColor] = [.red, .blue, .green, .yellow, .purple, .orange, .cyan, .magenta]
    
    private struct Particle {
        var position: CGPoint
        var velocity: CGPoint
        var color: UIColor
        var size: CGFloat
        var life: CGFloat
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startFireworks() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
        
        // 创建多个礼花
        for _ in 0..<7 {
            createFirework(at: CGPoint(x: CGFloat.random(in: 0...bounds.width),
                                     y: CGFloat.random(in: 0...bounds.height)))
        }
    }
    
    private func createFirework(at position: CGPoint) {
        let particleCount = 50
        for _ in 0..<particleCount {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 2...5)
            let velocity = CGPoint(x: cos(angle) * speed,
                                 y: sin(angle) * speed)
            
            particles.append(Particle(
                position: position,
                velocity: velocity,
                color: colors.randomElement() ?? .red,
                size: CGFloat.random(in: 2...4),
                life: 1.0
            ))
        }
    }
    
    @objc private func update() {
        // 更新粒子位置
        for i in 0..<particles.count {
            var particle = particles[i]
            particle.position.x += particle.velocity.x
            particle.position.y += particle.velocity.y
            particle.velocity.y += 0.1 // 重力效果
            particle.life -= 0.01
            particles[i] = particle
        }
        
        // 移除消失的粒子
        particles.removeAll { $0.life <= 0 }
        
        // 如果没有粒子了，停止动画
        if particles.isEmpty {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for particle in particles {
            context.setFillColor(particle.color.cgColor)
            context.setAlpha(particle.life)
            context.fillEllipse(in: CGRect(x: particle.position.x - particle.size/2,
                                         y: particle.position.y - particle.size/2,
                                         width: particle.size,
                                         height: particle.size))
        }
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        particles.removeAll()
        removeFromSuperview()
    }
}

class TimeTravelController: BasicController {
    
    var model: TimeTravelModel?
    private var customNavBar: UIView!
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var levelBubble: BubbleView!
    private var tableView: UITableView!
    private var currentProgressIndex = 0
    private var messages: [TravelMessageModel] = []
    private var canSelectOption = true
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeSimulation()
        setupBackgroundMusic()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBackgroundMusic()
    }
    
    private func setupBackgroundMusic() {
        guard let audioFileName = model?.audioFile,
              let audioPath = Bundle.main.path(forResource: audioFileName, ofType: "mp3") else {
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
    
    private func initializeSimulation() {
        messages.removeAll()
        currentProgressIndex = 0
        startSimulation()
    }
    
    override func setupUI() {
        super.setupUI()
        // 隐藏系统导航条
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 创建自定义导航条
        customNavBar = UIView()
        customNavBar.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        
        // 获取状态栏高度
        let statusBarHeight = UIDevice.statusBarHeight
        let navBarHeight = statusBarHeight + 44
        
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: navBarHeight)
        ])
        
        // 创建返回按钮
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            backButton.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: -8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 创建标题标签
        titleLabel = UILabel()
        titleLabel.text = model?.title ?? "时光旅行"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textAlignment = .center
        customNavBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: -8)
        ])
        
        // 创建等级气泡
        levelBubble = BubbleView(text: "", alignment: .center)
        view.addSubview(levelBubble)
        levelBubble.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            levelBubble.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 10),
            levelBubble.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            levelBubble.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
        // 创建TableView
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(TimeTravelMessageCell.self, forCellReuseIdentifier: "TimeTravelMessageCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: levelBubble.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 设置背景图片
        if let coverImage = model?.cover {
            let backgroundImageView = UIImageView(image: UIImage(named: coverImage))
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.frame = view.bounds
            backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(backgroundImageView, at: 0)
        }
    }
    
    private func startSimulation() {
        print("DEBUG: startSimulation called")
        guard let model = model else { return }
        
        // 显示标题和当前等级
        titleLabel.text = model.title
        updateLevelBubble()
        
        // 显示第一个进度
        showCurrentProgress()
    }
    
    private func updateLevelBubble() {
        guard let model = model else { return }
        
        // 确保在主线程更新UI
        DispatchQueue.main.async {
            self.levelBubble.removeFromSuperview()
            let levelStr = "你的等级: " + TimeTravelListModel.currentLevelDesc(model.ownStrength, tid: model.tid)
            self.levelBubble = BubbleView(text: levelStr, alignment: .center)
            self.view.addSubview(self.levelBubble)
            self.levelBubble.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.levelBubble.topAnchor.constraint(equalTo: self.customNavBar.bottomAnchor, constant: 10),
                self.levelBubble.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
                self.levelBubble.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24)
            ])
            
            // 更新tableView的约束
            if let tableViewTopConstraint = self.tableView.constraints.first(where: { $0.firstAttribute == .top }) {
                tableViewTopConstraint.isActive = false
            }
            self.tableView.topAnchor.constraint(equalTo: self.levelBubble.bottomAnchor, constant: 20).isActive = true
        }
    }
    
    private func showCurrentProgress() {
        print("DEBUG: showCurrentProgress called with index: \(currentProgressIndex)")
        guard let model = model,
              currentProgressIndex < model.progress.count else { return }
        
        let progress = model.progress[currentProgressIndex]
        
        // 清除现有消息
        messages.removeAll()
        
        // 添加标题消息
        messages.append(TravelMessageModel(type: .title(progress.title), alignment: .center))
        
        // 添加选项消息
        if let optionA = progress.A {
            messages.append(TravelMessageModel(type: .option(optionA.des, 0), alignment: .left))
        }
        if let optionB = progress.B {
            messages.append(TravelMessageModel(type: .option(optionB.des, 1), alignment: .left))
        }
        if let optionC = progress.C {
            messages.append(TravelMessageModel(type: .option(optionC.des, 2), alignment: .left))
        }
        
        print("DEBUG: messages count after adding: \(messages.count)")
        
        // 确保在主线程更新UI
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 使用淡入动画显示新内容
            self.tableView.alpha = 0
            self.tableView.reloadData()
            
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 1
            } completion: { _ in
                self.scrollToBottom()
            }
        }
    }
    
    private func handleOptionSelected(_ tag: Int) {
        guard canSelectOption,
              let model = model,
              currentProgressIndex < model.progress.count else { return }
        
        canSelectOption = false
        
        // 禁用tableView交互
        tableView.isUserInteractionEnabled = false
        
        // 获取选中的cell并设置选中状态
        if let selectedIndexPath = findOptionCellIndexPath(withTag: tag),
           let cell = tableView.cellForRow(at: selectedIndexPath) as? TimeTravelMessageCell {
            cell.updateSelected(true)
        }
        
        let progress = model.progress[currentProgressIndex]
        let selectedOption: TimeTravelSelectedModel?
        
        switch tag {
        case 0: selectedOption = progress.A
        case 1: selectedOption = progress.B
        case 2: selectedOption = progress.C
        default: return
        }
        
        guard let option = selectedOption,
              let result = option.result.randomElement() else { return }
        
        // 处理结果
        handleResult(result)
        
        // 显示旁白并等待
        if !result.vo.isEmpty {
            // 延迟一小段时间后插入旁白，让选中效果先显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let insertIndexPath = IndexPath(row: self.messages.count, section: 0)
                self.messages.append(TravelMessageModel(type: .narration(result.vo), alignment: .right))
                
                // 使用动画插入新的cell
                self.tableView.performBatchUpdates({
                    self.tableView.insertRows(at: [insertIndexPath], with: .fade)
                }) { _ in
                    // 插入完成后滚动到底部
                    self.scrollToBottom()
                    
                    // 2秒后开始切换到下一场景
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // 向左滑出动画
                        UIView.animate(withDuration: 0.3, animations: {
                            self.tableView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
                        }) { _ in
                            // 动画完成后，准备下一个场景
                            self.prepareNextScene(progress: progress, result: result)
                        }
                    }
                }
            }
        } else {
            // 如果没有旁白，延迟2秒后直接切换场景
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
                }) { _ in
                    self.prepareNextScene(progress: progress, result: result)
                }
            }
        }
    }
    
    private func handleResult(_ result: TimeSelectedResultModel) {
        guard var model = model else { return }
        
        switch result.operatorType {
        case .add:
            model.ownStrength = OwnStrengthType(rawValue: model.ownStrength.rawValue + result.level) ?? .unowned
        case .subt:
            model.ownStrength = OwnStrengthType(rawValue: model.ownStrength.rawValue - result.level) ?? .unowned
        case .rzero:
            model.ownStrength = .unowned
            showFailure()
            return
        case .gameover:
            showFailure()
            return
        case .unowned:
            break
        }
        
        self.model = model
        updateLevelBubble()
    }
    
    private func prepareNextScene(progress: TimeTravelItemModel, result: TimeSelectedResultModel) {
        // 如果已经显示了失败，就不再继续
        if result.operatorType == .gameover || result.operatorType == .rzero {
            return
        }
        
        // 恢复tableView的位置和交互
        self.tableView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        self.tableView.isUserInteractionEnabled = true
        
        // 检查是否需要跳转到下一个进度
        if progress.jumpNext {
            self.currentProgressIndex += 1
            if self.currentProgressIndex < self.model?.progress.count ?? 0 {
                self.showCurrentProgress()
            } else {
                self.checkFinalStatus()
            }
        } else {
            // 检查是否结束
            if result.operatorType == .gameover || result.operatorType == .rzero {
                if self.model?.ownStrength.rawValue ?? 0 < 1 {
                    self.showFailure()
                } else {
                    self.currentProgressIndex += 1
                    if self.currentProgressIndex < self.model?.progress.count ?? 0 {
                        self.showCurrentProgress()
                    } else {
                        self.checkFinalStatus()
                    }
                }
            } else {
                // 如果不是结束状态，也需要继续下一个进度
                self.currentProgressIndex += 1
                if self.currentProgressIndex < self.model?.progress.count ?? 0 {
                    self.showCurrentProgress()
                } else {
                    self.checkFinalStatus()
                }
            }
        }
        
        // 恢复选项可选状态
        self.canSelectOption = true
        
        // 从右向左滑入动画
        UIView.animate(withDuration: 0.3) {
            self.tableView.transform = .identity
        }
    }
    
    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let lastRow = messages.count - 1
        let indexPath = IndexPath(row: lastRow, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func checkFinalStatus() {
        guard let model = model else { return }
        
        switch model.tid {
        case 1: // 修仙模式
            if model.ownStrength == .xianren {
                showSuccess()
            } else {
                showFailure()
            }
        case 2: // 创业模式
            if model.ownStrength.rawValue >= 11 {
                showSuccess()
            } else {
                showFailure()
            }
        case 3: // 荒岛求生模式
            if model.ownStrength.rawValue >= 11 {
                showSuccess()
            } else {
                showFailure()
            }
        default:
            showFailure()
        }
    }
    
    private func showSuccess() {
        guard let model = model else { return }
        
        let title: String
        let message: String
        
        switch model.tid {
        case 1:
            title = "修仙成功"
            message = "恭喜你成功飞升成仙！"
        case 2:
            title = "创业成功"
            message = "恭喜你成为商业大亨！"
        case 3:
            title = "求生成功"
            message = "恭喜你成功获救！"
        default:
            title = "成功"
            message = "恭喜你完成任务！"
        }
        
        // 创建并添加礼花动画视图
        let fireworksView = FireworksView(frame: view.bounds)
        view.addSubview(fireworksView)
        fireworksView.startFireworks()
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // 停止并移除礼花动画
                fireworksView.stop()
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(alert, animated: true)
       
    }
    
    private func showFailure() {
        guard let model = model else { return }
        
        let title: String
        let message: String
        
        switch model.tid {
        case 1:
            title = "修仙失败"
            message = "你的修仙之路到此为止..."
        case 2:
            title = "创业失败"
            message = "你的创业梦想未能实现..."
        case 3:
            title = "求生失败"
            message = "你未能在这片荒岛上生存下去..."
        default:
            title = "失败"
            message = "任务未能完成..."
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            self.backButtonTapped()
        })
        present(alert, animated: true)
    }
    
    @objc private func backButtonTapped() {
        // 使用自定义转场动画
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        }) { [weak self] _ in
            self?.navigationController?.popViewController(animated: false)
        }
    }
    
    private func findOptionCellIndexPath(withTag tag: Int) -> IndexPath? {
        for (index, message) in messages.enumerated() {
            if case .option(_, let messageTag) = message.type, messageTag == tag {
                return IndexPath(row: index, section: 0)
            }
        }
        return nil
    }
}

extension TimeTravelController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG: numberOfRowsInSection called, count: \(messages.count)")
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG: cellForRowAt called for index: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTravelMessageCell", for: indexPath) as! TimeTravelMessageCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        if case .option(_, let tag) = message.type {
            handleOptionSelected(tag)
        }
    }
}
