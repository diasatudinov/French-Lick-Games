import Foundation

class ProcessingData: NSObject, URLSessionTaskDelegate {
    func resolveIt(from originalURL: URL, completion: @escaping (URL?) -> Void) {
        var request = URLRequest(url: originalURL)
        request.setValue("CFNetwork", forHTTPHeaderField: "User-Agent")

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error:", error.localizedDescription)
                completion(nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, let finalURL = httpResponse.url {
                completion(finalURL)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
       
        completionHandler(request)
    }
    
    
    static func checking() async -> Bool {
        let urlString = AppLinks.winStarData
        
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            
            let handler = ProcessingData()
            
            return await withCheckedContinuation { continuation in
                handler.resolveIt(from: url) { finalURL in
                    if let finalURL {
                        continuation.resume(returning: finalURL.host?.contains("google") ?? true)
                    } else {
                        continuation.resume(returning: true)
                    }
                    
                }
            }
            
        } else {
            return false
        }
    }
    
}
