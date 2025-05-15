import Foundation
import RealmSwift

class UserManager {
    static let shared = UserManager()
    
    private let userDefaultsKey = "isUserLoggedIn"
        
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: userDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
        }
    }
    
    private let realm: Realm
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "currentUserUID"
    
    private(set) var currentUser: UserModel
    
    private init() {
        // 配置 Realm
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: RealmUserModel.className()) { oldObject, newObject in
                        newObject?["account"] = ""
                        newObject?["password"] = ""
                    }
                }
            },
            deleteRealmIfMigrationNeeded: true
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            realm = try Realm()
        } catch {
            if let realmURL = config.fileURL {
                try? FileManager.default.removeItem(at: realmURL)
            }
            
            do {
                realm = try Realm()
            } catch {
                fatalError("Failed to initialize Realm after cleanup: \(error)")
            }
        }
        
        // 初始化当前用户
        if let savedUID = userDefaults.string(forKey: currentUserKey),
           let realmUser = realm.object(ofType: RealmUserModel.self, forPrimaryKey: savedUID) {
            currentUser = realmUser.toUserModel()
        } else {
            // 创建新用户
            currentUser = UserModel()
            saveCurrentUser()
        }
    }
    
    // MARK: - Public Methods
    
    /// 生成随机账号和密码
    func generateRandomAccount() -> (account: String, password: String) {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let accountLength = 8
        let passwordLength = 12
        
        let account = String((0..<accountLength).map { _ in letters.randomElement()! })
        let password = String((0..<passwordLength).map { _ in letters.randomElement()! })
        
        return (account, password)
    }
    
    /// 使用账号密码登录
    func login(account: String, password: String) -> Bool {
        // 查找用户
        guard let realmUser = realm.objects(RealmUserModel.self)
            .filter("account == %@ AND password == %@", account, password)
            .first else {
            return false
        }
        
        // 更新当前用户
        currentUser = realmUser.toUserModel()
        userDefaults.set(currentUser.uid, forKey: currentUserKey)
        isLoggedIn = true
        
        return true
    }
    
    /// 创建新用户
    func createUser(account: String, password: String) -> UserModel {
        let newUser = UserModel(
            uid: UUID().uuidString,
            account: account,
            password: password,
            nickname: "用户\(String(account.prefix(4)))"
        )
        
        let realmUser = RealmUserModel(user: newUser)
        
        do {
            try realm.write {
                realm.add(realmUser)
            }
        } catch {
            print("Error creating user: \(error.localizedDescription)")
        }
        
        return newUser
    }
    
    /// 保存当前用户信息
    func saveCurrentUser() {
        let realmUser = RealmUserModel(user: currentUser)
        
        do {
            try realm.write {
                realm.add(realmUser, update: .modified)
            }
            userDefaults.set(currentUser.uid, forKey: currentUserKey)
        } catch {
            print("Error saving current user: \(error.localizedDescription)")
        }
    }
    
    /// 更新用户信息
    func updateUser(nickname: String? = nil,
                   avatar: String? = nil,
                   gender: Int? = nil,
                   age: Int? = nil,
                   signature: String? = nil) {
        // 更新内存中的用户信息
        if let nickname = nickname {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: nickname,
                avatar: currentUser.avatar,
                gender: currentUser.gender,
                age: currentUser.age,
                signature: currentUser.signature
            )
        }
        
        if let avatar = avatar {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: avatar,
                gender: currentUser.gender,
                age: currentUser.age,
                signature: currentUser.signature
            )
        }
        
        if let gender = gender {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: currentUser.avatar,
                gender: gender,
                age: currentUser.age,
                signature: currentUser.signature
            )
        }
        
        if let age = age {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: currentUser.avatar,
                gender: currentUser.gender,
                age: age,
                signature: currentUser.signature
            )
        }
        
        if let signature = signature {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: currentUser.avatar,
                gender: currentUser.gender,
                age: currentUser.age,
                signature: signature
            )
        }
        
        // 保存到数据库
        saveCurrentUser()
    }
    
    /// 切换用户
    func switchUser(_ user: UserModel) {
        currentUser = user
        saveCurrentUser()
    }
    
    /// 登出当前用户
    func logout() {
        currentUser = UserModel()
        saveCurrentUser()
    }
    
    /// 获取用户信息
    func getUser(uid: String) -> UserModel? {
        guard let realmUser = realm.object(ofType: RealmUserModel.self, forPrimaryKey: uid) else {
            return nil
        }
        return realmUser.toUserModel()
    }
    
    /// 删除用户
    func deleteUser(uid: String) {
        guard let realmUser = realm.object(ofType: RealmUserModel.self, forPrimaryKey: uid) else {
            return
        }
        
        do {
            try realm.write {
                realm.delete(realmUser)
            }
        } catch {
            print("Error deleting user: \(error.localizedDescription)")
        }
    }
} 
