import Foundation

class ULNetworker {
    
    //MARK: - Private properties
    
    private let urlSession      = URLSession(configuration: .default)
    private let serialQueue     = DispatchQueue(label: "serialQueue.ULNetworker")
    private var executableTasks = [URL : URLSessionDataTask]()
    
    //MARK: - Public methods
    
    func exequteTask(request: URLRequest, complitionHandler: @escaping (Data?, URLResponse?, Error?)->()) {
        guard let url = request.url else { fatalError("Failed to receive url from request")}
        
        let task = urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            
            complitionHandler(data, response, error)
            self?.removeTaskFromExecutableTasks(byUrl: url)
        }
        addToExecutableTasks(task: task, byURL: url)
        task.resume()
    }
    
    func exequteTask(url: URL, complitionHandler: @escaping (Data?, URLResponse?, Error?)->()) {
        let task = urlSession.dataTask(with: url) { [weak self] (data, response, error) in
            
            complitionHandler(data, response, error)
            self?.removeTaskFromExecutableTasks(byUrl: url)
        }
        addToExecutableTasks(task: task, byURL: url)
        task.resume()
    }
    
    func isSucccess(response: URLResponse?) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        
        if (200 ..< 300).contains(httpResponse.statusCode) {
            return true
        }
        return false
    }
    
    func containsTaskBy(url: URL) -> (answer: Bool, taskState: URLSessionDataTask.State) {
        var answer      = false
        var taskState   = URLSessionDataTask.State.suspended
        
        serialQueue.sync { [weak self] in
            if  let wSelf = self, let task = wSelf.executableTasks[url] {
                answer = true
                taskState = task.state
            }
        }
        return (answer, taskState)
    }
    
    func resumeTaskBy(url: URL) {
        serialQueue.async { [weak self] in
            self?.executableTasks[url]?.resume()
        }
    }
    
    func suspendTaskBy(url: URL) {
        serialQueue.async { [weak self] in
            self?.executableTasks[url]?.suspend()
        }
    }
    
    func cancelTaskBy(url: URL) {
        serialQueue.async { [weak self] in
            let task = self?.executableTasks.removeValue(forKey: url)
            task?.cancel()
        }
    }
    
    //MARK: - Private methods
    
    private func addToExecutableTasks(task: URLSessionDataTask, byURL url: URL) {
        serialQueue.sync { [weak self] in
            self?.executableTasks[url] = task
        }
    }
    
    private func removeTaskFromExecutableTasks(byUrl url: URL) {
        serialQueue.sync { [weak self] in
            _ = self?.executableTasks.removeValue(forKey: url)
        }
    }
}
