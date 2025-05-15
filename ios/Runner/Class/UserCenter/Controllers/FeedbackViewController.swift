import UIKit
// import PhotosUI // Will be replaced by HXPhotoPicker import if needed, or ensure it's imported if PhotoPickerController requires it.
// Assuming HXPhotoPicker is globally available or will be imported later.

class FeedbackViewController: BasicController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "请输入您的意见或建议..."
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        // Changed to named image and set up for displaying selected image
        button.setBackgroundImage(UIImage(named: "icon_addPic"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("提交", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // private var selectedImages: [UIImage] = [] // Removed
    private var selectedImage: UIImage? // Added for single image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // setupCollectionView() // Removed
        setupActions()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "意见反馈"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)
        // contentView.addSubview(imageCollectionView) // Removed
        contentView.addSubview(addImageButton)
        contentView.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            
            // Updated addImageButton constraints (was imageCollectionView)
            addImageButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            addImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            // addImageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), // Making it a fixed size square
            addImageButton.widthAnchor.constraint(equalToConstant: 100),
            addImageButton.heightAnchor.constraint(equalToConstant: 100),
            
            // submitButton constraints updated to be relative to addImageButton
            submitButton.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    // private func setupCollectionView() { ... } // Removed
    
    private func setupActions() {
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        textView.delegate = self
    }
    
    @objc private func addImageButtonTapped() {
        
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
        var cameraConfig = CameraConfiguration()
        cameraConfig.sessionPreset = .hd1920x1080
        cameraConfig.modalPresentationStyle = .fullScreen
        config.photoList.cameraType = .custom(cameraConfig)

        let picker = PhotoPickerController(config: config)
        picker.pickerDelegate = self
        self.present(picker, animated: true)
    }
    
    @objc private func submitButtonTapped() {
        guard !textView.text.isEmpty else {
            let alert = UIAlertController(title: "提示", message: "请输入反馈内容", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        // TODO: Implement submission logic with self.selectedImage
        if let image = selectedImage {
            print("Submitting with image: \\(image)")
            // Convert image to data or upload as needed
        } else {
            print("Submitting without an image")
        }
        
        let alert = UIAlertController(title: "提交成功", message: "感谢您的反馈！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

// MARK: - PHPickerViewControllerDelegate
extension FeedbackViewController: PhotoPickerControllerDelegate {
    func pickerController(_ pickerController: PhotoPickerController, didFinishSelection result: PickerResult) {
        pickerController.dismiss(true) {
            guard let asset = result.photoAssets.first else { return }
            self.addImageButton.setBackgroundImage(asset.originalImage, for: .normal)
            self.selectedImage = asset.originalImage
        }
    }
}
