import Foundation
import RealmSwift

// 用于 UI 展示和数据传输的用户模型
struct UserModel: Codable {
    let uid: String
    let account: String
    let password: String
    var nickname: String
    var avatar: String
    var gender: Int // 0: 未知, 1: 男, 2: 女
    var age: Int
    var signature: String
    
    init(uid: String = UUID().uuidString,
         account: String = "",
         password: String = "",
         nickname: String = "",
         avatar: String = "",
         gender: Int = 0,
         age: Int = 0,
         signature: String = "") {
        self.uid = uid
        self.account = account
        self.password = password
        self.nickname = nickname
        self.avatar = avatar
        self.gender = gender
        self.age = age
        self.signature = signature
    }
}

// Realm 数据库存储的用户模型
class RealmUserModel: Object {
    @Persisted(primaryKey: true) var uid: String
    @Persisted var account: String
    @Persisted var password: String
    @Persisted var nickname: String
    @Persisted var avatar: String
    @Persisted var gender: Int
    @Persisted var age: Int
    @Persisted var signature: String
    @Persisted var lastLoginTime: Date
    
    convenience init(user: UserModel) {
        self.init()
        self.uid = user.uid
        self.account = user.account
        self.password = user.password
        self.nickname = user.nickname
        self.avatar = user.avatar
        self.gender = user.gender
        self.age = user.age
        self.signature = user.signature
        self.lastLoginTime = Date()
    }
    
    func toUserModel() -> UserModel {
        return UserModel(
            uid: uid,
            account: account,
            password: password,
            nickname: nickname,
            avatar: avatar,
            gender: gender,
            age: age,
            signature: signature
        )
    }
    
    override static func primaryKey() -> String? {
        return "uid"
    }
} 