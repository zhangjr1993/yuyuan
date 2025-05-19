import Foundation
import SmartCodable

struct MessageModel: Codable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
    let senderName: String
    let senderAvatar: String
    
    init(id: String = UUID().uuidString,
         content: String,
         isUser: Bool,
         senderName: String,
         senderAvatar: String,
         timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.senderName = senderName
        self.senderAvatar = senderAvatar
    }
}

struct StoryChatInfoModel: SmartCodable {
    var name: String = ""
    var intro: String = ""
    var mid = 0
    var audioFile = ""
    var actInfo: ActModel = ActModel()
}
