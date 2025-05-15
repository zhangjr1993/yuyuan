import Foundation
import RealmSwift

class ChatMessageModel: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var mid: String
    @Persisted var actId: String
    @Persisted var uid: String
    @Persisted var content: String
    @Persisted var isUser: Bool
    @Persisted var senderName: String
    @Persisted var senderAvatar: String
    @Persisted var timestamp: Date
    
    convenience init(message: MessageModel, mid: String, actId: String, uid: String) {
        self.init()
        self.id = message.id
        self.mid = mid
        self.actId = actId
        self.uid = uid
        self.content = message.content
        self.isUser = message.isUser
        self.senderName = message.senderName
        self.senderAvatar = message.senderAvatar
        self.timestamp = message.timestamp
    }
    
    func toMessageModel() -> MessageModel {
        return MessageModel(
            id: id,
            content: content,
            isUser: isUser,
            senderName: senderName,
            senderAvatar: senderAvatar,
            timestamp: timestamp
        )
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
} 