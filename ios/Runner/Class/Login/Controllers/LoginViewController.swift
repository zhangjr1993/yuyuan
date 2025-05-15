import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private var generatedAccount: String?
    private var generatedPassword: String?
    
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchbg3")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "欢迎回来"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "登录以继续"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "用户名"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_suiji"), for: .normal)
        return button
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTextFieldDelegates()
        
        // 自动生成账号密码
        generateRandomAccount()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(usernameTextField)
        containerView.addSubview(randomButton)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(loginButton)
        
        [backgroundImageView, containerView, titleLabel, subtitleLabel,
         usernameTextField, randomButton, passwordTextField, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            usernameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            usernameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            usernameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            randomButton.centerYAnchor.constraint(equalTo: usernameTextField.centerYAnchor),
            randomButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -36),
            randomButton.widthAnchor.constraint(equalToConstant: 24),
            randomButton.heightAnchor.constraint(equalToConstant: 24),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32),
            
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTextFieldDelegates() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        randomButton.addTarget(self, action: #selector(randomButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    private func generateRandomAccount() {
        let (account, password) = UserManager.shared.generateRandomAccount()
        generatedAccount = account
        generatedPassword = password
        
        usernameTextField.text = account
        passwordTextField.text = password
    }
   
    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "提示", message: "请输入用户名和密码")
            return
        }
        
        // 如果是新生成的账号密码，创建新用户
        if username == generatedAccount && password == generatedPassword {
            let _ = UserManager.shared.createUser(account: username, password: password)
        }
        
        // 尝试登录
        if UserManager.shared.login(account: username, password: password) {
            // 登录成功，切换到主界面
            let tabBarController = BasicTabBarController()
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true)
        } else {
            showAlert(title: "提示", message: "账号或密码错误")
        }
    }
    
    @objc private func randomButtonTapped() {
        generateRandomAccount()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == usernameTextField {
            return newText.count <= 15
        } else if textField == passwordTextField {
            return newText.count <= 16
        }
        
        return true
    }
} 
