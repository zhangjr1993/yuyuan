import Foundation

class AIService {
    private let apiKey: String
    private let baseURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendMessage(_ message: String, roleSettings: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                
        let requestBody: [String: Any] = [
            "model": "glm-4-flash",
            "messages": [
                ["role": "system", "content": roleSettings],
                ["role": "user", "content": message]
            ],
            "temperature": 0.7,
            "top_p": 0.7,
            "max_tokens": 1500,
            "stream": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            // 打印请求信息用于调试
            print("Request URL: \(url)")
            print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let bodyData = request.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("Request Body: \(bodyString)")
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 打印响应信息用于调试
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No Data Received")
                completion(.failure(NSError(domain: "AIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // 打印响应数据用于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = json["error"] as? [String: Any] {
                        // 处理API返回的错误
                        let errorMessage = (error["message"] as? String) ?? "Unknown error"
                        throw NSError(domain: "AIService", code: -4, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    }
                    
                    if let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        completion(.success(content))
                    } else {
                        throw NSError(domain: "AIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                } else {
                    throw NSError(domain: "AIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
} 
