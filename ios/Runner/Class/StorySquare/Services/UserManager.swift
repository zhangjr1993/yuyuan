import Foundation
import RealmSwift

class UserManager {
    static let shared = UserManager()
    
    private let userDefaultsKey = "isUserLoggedIn"
    private let membershipExpiryKeyPrefix = "membershipExpiryDate_"
        
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: userDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
        }
    }
    
    private func getMembershipExpiryKey() -> String {
        return membershipExpiryKeyPrefix + currentUser.uid
    }
    
    var membershipExpiryDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: getMembershipExpiryKey()) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: getMembershipExpiryKey())
        }
    }
    
    var isMembershipValid: Bool {
        guard let expiryDate = membershipExpiryDate else { return false }
        return expiryDate > Date()
    }
    
    var membershipDaysRemaining: String {
        guard let expiryDate = membershipExpiryDate else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: expiryDate)
    }
    
    var actIdArray: [Int] {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "UserLockActIds")
        }
        get {
            if let value = UserDefaults.standard.value(forKey: "UserLockActIds") as? [Int] {
                return value
            }else {
                return []
            }
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
                   signature: String? = nil,
                   coin: Int? = nil) {
        // 更新内存中的用户信息
        if let nickname = nickname {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: nickname,
                avatar: currentUser.avatar,
                gender: currentUser.gender,
                age: currentUser.age,
                signature: currentUser.signature,
                coin: currentUser.coin
            )
        }
        
        if let avatar = avatar {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: avatar,
                gender: currentUser.gender,
                age: currentUser.age,
                signature: currentUser.signature,
                coin: currentUser.coin
            )
        }
        
        if let gender = gender {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: currentUser.avatar,
                gender: gender,
                age: currentUser.age,
                signature: currentUser.signature,
                coin: currentUser.coin
            )
        }
        
        if let age = age {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: currentUser.avatar,
                gender: currentUser.gender,
                age: age,
                signature: currentUser.signature,
                coin: currentUser.coin
            )
        }
        
        if let signature = signature {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: currentUser.avatar,
                gender: currentUser.gender,
                age: currentUser.age,
                signature: signature,
                coin: currentUser.coin
            )
        }
        
        if let coin = coin {
            currentUser = UserModel(
                uid: currentUser.uid,
                nickname: currentUser.nickname,
                avatar: currentUser.avatar,
                gender: currentUser.gender,
                age: currentUser.age,
                signature: currentUser.signature,
                coin: coin
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
    
    /// 更新会员信息
    func updateMembership(productId: String) {
        let calendar = Calendar.current
        let now = Date()
        
        // 根据产品ID设置不同的会员时长
        var daysToAdd: Int = 0
        switch productId {
        case "com.fujinyy.keyuyuan2":
            daysToAdd = 90
        default:
            daysToAdd = 30
        }
        
        // 如果已有会员，在现有到期时间基础上增加天数
        if let currentExpiry = membershipExpiryDate, currentExpiry > now {
            membershipExpiryDate = calendar.date(byAdding: .day, value: daysToAdd, to: currentExpiry)
        } else {
            // 如果没有会员或已过期，从当前时间开始计算
            membershipExpiryDate = calendar.date(byAdding: .day, value: daysToAdd, to: now)
        }
    }
} 
