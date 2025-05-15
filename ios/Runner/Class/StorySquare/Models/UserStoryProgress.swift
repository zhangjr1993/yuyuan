import Foundation

struct UserStoryProgress: Codable {
    let userId: Int      // 用户ID
    let storyId: Int     // 故事ID
    var currentActTitle: String  // 当前场景标题
    var lastUpdateTime: Date     // 最后更新时间
    
    init(userId: Int, storyId: Int, currentActTitle: String) {
        self.userId = userId
        self.storyId = storyId
        self.currentActTitle = currentActTitle
        self.lastUpdateTime = Date()
    }
    
    // 创建唯一标识符
    var uniqueKey: String {
        return "\(userId)_\(storyId)"
    }
}

// MARK: - UserDefaults Storage Manager
class UserStoryProgressManager {
    static let shared = UserStoryProgressManager()
    
    private let defaults = UserDefaults.standard
    private let storageKey = "user_story_progress_list"
    
    private init() {}
    
    // 保存或更新进度
    func saveProgress(_ progress: UserStoryProgress) {
        var progressList = getAllProgress()
        
        // 查找是否存在相同的进度记录
        if let index = progressList.firstIndex(where: { $0.uniqueKey == progress.uniqueKey }) {
            progressList[index] = progress
        } else {
            progressList.append(progress)
        }
        
        // 保存到 UserDefaults
        if let encoded = try? JSONEncoder().encode(progressList) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
    // 获取特定用户的特定故事进度
    func getProgress(userId: Int, storyId: Int) -> UserStoryProgress? {
        let progressList = getAllProgress()
        return progressList.first { $0.userId == userId && $0.storyId == storyId }
    }
    
    // 获取所有进度
    func getAllProgress() -> [UserStoryProgress] {
        guard let data = defaults.data(forKey: storageKey),
              let progressList = try? JSONDecoder().decode([UserStoryProgress].self, from: data) else {
            return []
        }
        return progressList
    }
    
    // 获取特定用户的所有故事进度
    func getUserProgress(userId: Int) -> [UserStoryProgress] {
        return getAllProgress().filter { $0.userId == userId }
    }
    
    // 删除特定进度
    func deleteProgress(userId: Int, storyId: Int) {
        var progressList = getAllProgress()
        progressList.removeAll { $0.userId == userId && $0.storyId == storyId }
        
        if let encoded = try? JSONEncoder().encode(progressList) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
    // 删除用户的所有进度
    func deleteAllUserProgress(userId: Int) {
        var progressList = getAllProgress()
        progressList.removeAll { $0.userId == userId }
        
        if let encoded = try? JSONEncoder().encode(progressList) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
    // 清除所有进度
    func clearAllProgress() {
        defaults.removeObject(forKey: storageKey)
    }
}
