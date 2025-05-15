import Foundation
import RealmSwift

class ChatDatabaseManager {
    static let shared = ChatDatabaseManager()
    
    private let pageSize = 20
    private let realm: Realm
    
    private init() {
        // 配置 Realm
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                // 处理数据库迁移
                if oldSchemaVersion < 1 {
                    // 未来版本更新时在这里处理数据迁移
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func saveMessage(_ message: MessageModel, mid: String, actId: String, uid: String) {
        let chatMessage = ChatMessageModel(message: message, mid: mid, actId: actId, uid: uid)
        
        do {
            try realm.write {
                realm.add(chatMessage, update: .modified)
            }
        } catch {
            print("Error saving message: \(error.localizedDescription)")
        }
    }
    
    func getMessages(mid: String, actId: String, uid: String, page: Int = 0) -> [MessageModel] {
        let messages = realm.objects(ChatMessageModel.self)
            .filter("mid == %@ AND actId == %@ AND uid == %@", mid, actId, uid)
            .sorted(byKeyPath: "timestamp", ascending: false)
        
        let start = page * pageSize
        let end = min(start + pageSize, messages.count)
        
        guard start < messages.count else { return [] }
        
        return Array(messages[start..<end]).map { $0.toMessageModel() }
    }
    
    func getMessageCount(mid: String, actId: String, uid: String) -> Int {
        return realm.objects(ChatMessageModel.self)
            .filter("mid == %@ AND actId == %@ AND uid == %@", mid, actId, uid)
            .count
    }
    
    func clearMessages(mid: String, actId: String, uid: String) {
        let messages = realm.objects(ChatMessageModel.self)
            .filter("mid == %@ AND actId == %@ AND uid == %@", mid, actId, uid)
        
        do {
            try realm.write {
                realm.delete(messages)
            }
        } catch {
            print("Error clearing messages: \(error.localizedDescription)")
        }
    }
} 