import UIKit
import PhotosUI

class EditProfileController: BasicController {
    
    private var selectedImage: UIImage?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .systemGroupedBackground
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    private let avatarCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let avatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 44
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.setBackgroundImage(UIImage(named: "default_avatar"), for: .normal)
        // 添加轻微的阴影效果
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    private let changeAvatarLabel: UILabel = {
        let label = UILabel()
        label.text = "点击更换头像"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let nicknameCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "昵称"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入昵称"
        textField.font = .systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.textAlignment = .right
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("保存", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        // 添加渐变效果
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemBlue.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        button.layer.insertSublayer(gradientLayer, at: 0)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变层的frame
        if let gradientLayer = saveButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = saveButton.bounds
        }
    }
    
    // MARK: - UI Setup
    override func setupUI() {
        super.setupUI()
        
        title = "编辑个人信息"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(avatarCard)
        avatarCard.addSubview(avatarButton)
        avatarCard.addSubview(changeAvatarLabel)
        
        contentView.addSubview(nicknameCard)
        nicknameCard.addSubview(nicknameLabel)
        nicknameCard.addSubview(nicknameTextField)
        
        contentView.addSubview(saveButton)
        
        var image: UIImage?
        if let imgData = Data(base64Encoded: UserManager.shared.currentUser.avatar, options: .ignoreUnknownCharacters), imgData.count > 0 {
            image = UIImage(data: imgData)
        }else {
            image = UIImage(named: "default_avatar")
        }
        avatarButton.setBackgroundImage(image, for: .normal)
        nicknameTextField.text = UserManager.shared.currentUser.nickname.count > 0 ? UserManager.shared.currentUser.nickname : ""
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [scrollView, contentView, avatarCard, avatarButton, changeAvatarLabel,
         nicknameCard, nicknameLabel, nicknameTextField, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Avatar Card
            avatarCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            avatarCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Avatar Button
            avatarButton.topAnchor.constraint(equalTo: avatarCard.topAnchor, constant: 20),
            avatarButton.centerXAnchor.constraint(equalTo: avatarCard.centerXAnchor),
            avatarButton.widthAnchor.constraint(equalToConstant: 88),
            avatarButton.heightAnchor.constraint(equalToConstant: 88),
            
            // Change Avatar Label
            changeAvatarLabel.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: 12),
            changeAvatarLabel.centerXAnchor.constraint(equalTo: avatarCard.centerXAnchor),
            changeAvatarLabel.bottomAnchor.constraint(equalTo: avatarCard.bottomAnchor, constant: -20),
            
            // Nickname Card
            nicknameCard.topAnchor.constraint(equalTo: avatarCard.bottomAnchor, constant: 20),
            nicknameCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nicknameCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nicknameCard.heightAnchor.constraint(equalToConstant: 54),
            
            // Nickname Label
            nicknameLabel.leadingAnchor.constraint(equalTo: nicknameCard.leadingAnchor, constant: 16),
            nicknameLabel.centerYAnchor.constraint(equalTo: nicknameCard.centerYAnchor),
            
            // Nickname TextField
            nicknameTextField.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 16),
            nicknameTextField.trailingAnchor.constraint(equalTo: nicknameCard.trailingAnchor, constant: -16),
            nicknameTextField.centerYAnchor.constraint(equalTo: nicknameCard.centerYAnchor),
            nicknameTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            // Save Button
            saveButton.topAnchor.constraint(equalTo: nicknameCard.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        avatarButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        nicknameTextField.delegate = self
    }
    
    @objc private func avatarButtonTapped() {
        var config = PickerConfiguration()
        config.languageType = .english

        config.pickerPresentStyle = .present()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .single
        config.selectOptions = [.photo]
        config.allowSelectedTogether = false
        config.maximumSelectedCount = 1
        config.photoSelectionTapAction = .openEditor
        config.creationDate = false
        config.photoList.sort = .desc
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoList.isSaveSystemAlbum = false
//        // 编辑模式
//        let tools: EditorConfiguration.ToolsView = {
//            let cropSize = EditorConfiguration.ToolsView.Options(imageType: .local("hx_editor_photo_crop"), type: .cropSize)
//            return .init(toolOptions: [cropSize])
//        }()
//        config.editor.toolsView = tools
        config.editor.photo.defaultSelectedToolOption = .cropSize
        config.editor.cropSize.aspectRatios = []
        config.editor.isFixedCropSizeState = true
        config.editor.cropSize.isFixedRatio = true
        config.editor.cropSize.aspectRatio = .init(width: 1, height: 1)
        
        var cameraConfig = CameraConfiguration()
        cameraConfig.sessionPreset = .hd1920x1080
        cameraConfig.modalPresentationStyle = .fullScreen
        cameraConfig.editor.cropSize.aspectRatio = .init(width: 1, height: 1)
        cameraConfig.editor.cropSize.isFixedRatio = true
        cameraConfig.editor.cropSize.aspectRatios = []
        cameraConfig.editor.cropSize.isResetToOriginal = false
        cameraConfig.editor.isFixedCropSizeState = true
        config.photoList.cameraType = .custom(cameraConfig)

        let picker = PhotoPickerController(config: config)
        picker.pickerDelegate = self
        self.present(picker, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            showAlert(title: "提示", message: "请输入昵称")
            return
        }
        
        if let image = selectedImage {
            // 将图片转换为Base64字符串
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let base64String = imageData.base64EncodedString()
                UserManager.shared.updateUser(nickname: nickname, avatar: base64String)
            }
        } else {
            UserManager.shared.updateUser(nickname: nickname)
        }
        
        // TODO: 保存用户信息到本地或服务器
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension EditProfileController: PhotoPickerControllerDelegate {
    func pickerController(_ pickerController: PhotoPickerController, didFinishSelection result: PickerResult) {
        pickerController.dismiss(true) {
            guard let asset = result.photoAssets.first else { return }
            self.avatarButton.setBackgroundImage(asset.originalImage, for: .normal)
            self.selectedImage = asset.originalImage
        }
    }
}

// MARK: - UITextFieldDelegate
extension EditProfileController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
