import Foundation
import SmartCodable

// MARK: - StoryList
struct StoryList: SmartCodable {
    var movies: [StoryModel] = []
    var novel: [StoryModel] = []
    var drama: [StoryModel] = []
}

// MARK: - Story
struct StoryModel: SmartCodable {
    var name: String = ""
    var audioFile = ""
    var cover: String = ""
    var chatNum: Int = 0
    var mid: Int = 0
    var intro: String = ""
    var act: [ActModel] = []
}

// MARK: - Act
struct ActModel: SmartCodable {
    var actId = 0
    var title: String = ""
    var desc: String = ""
    var background: String = ""
    var playRole = RoleModel()
    var aiRole = RoleModel()
}

// MARK: - Role
struct RoleModel: SmartCodable {
    var name: String = ""
    var sex: String = ""
    var age: Int = 0
    var profile: String = ""
    var headpic = ""
}

// MARK: - Usage Example Extension
extension StoryList {
    static func loadFromFile() -> StoryList? {
        guard let url = Bundle.main.url(forResource: "StoryList", withExtension: "geojson"),
              let data = try? Data(contentsOf: url),
              let jsonDic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return StoryList.deserialize(from: jsonDic)
    }
} 
