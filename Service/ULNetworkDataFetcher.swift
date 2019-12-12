import Foundation

class ULNetworkDataFetcher {
    private typealias ComplitionHandlerType = (success:((Data) -> Void)?, failure: ((Error) -> Void)?)
    
    //MARK: - Private properties
    
    private let networker   = ULNetworker()
    private let serialQueue = DispatchQueue(label: "SerialQueue.NetworkDataFetcher")
    private let concurentQueue = DispatchQueue(label: "ConcurentQueue.NetworkDataFetcher", attributes: .concurrent)
    
    private var dataCache   = NSCache<NSString, NSData>()
    private var complitionHandlers = [URL : ComplitionHandlerType]()
    
    //MARK: - Public methods
    
    func pauseDataPrefetchingBy(urls: [URL]) {
        urls.forEach { networker.suspendTaskBy(url: $0) }
    }
    
    func asyncFetchData(by url: URL,
                   successBlock: ((Data)->Void)? = nil,
                   failureBlock: ((Error)->Void)? = nil) {
        
        
        serialQueue.sync { [weak self] in
            guard let wSelf = self else { return }
            
            if let dataFromCache = wSelf.dataFromCache(by: url) {
                successBlock?(dataFromCache as Data)
                return
            }
            
            switch wSelf.networker.containsTaskBy(url: url) {
                
            case (true, .running):
                ifNeedSave(complitionHandler: (successBlock, failureBlock), by: url)
                
            case (true, .suspended):
                ifNeedSave(complitionHandler: (successBlock, failureBlock), by: url)
                networker.resumeTaskBy(url: url)
            
            case (false, _):
                wSelf.ifNeedSave(complitionHandler: (successBlock, failureBlock), by: url)
                wSelf.startLoadData(by: url)

            default:
                break
            }
        }
    }
    
    func asyncPrefechDataBy(urls: [URL]) {
        concurentQueue.async { [weak self] in
            urls.forEach { self?.asyncFetchData(by: $0) }
        }
    }
    
    //MARK: - private methods
    
    private func ifNeedSave(complitionHandler: ComplitionHandlerType, by url: URL) {
        if complitionHandler.success != nil {
            complitionHandlers[url] = complitionHandler
        }
    }
    
    private func dataFromCache(by url: URL) -> Data? {
        return dataCache.object(forKey: url.absoluteString as NSString) as Data?
    }
    
    private func startLoadData(by url: URL) {
        networker.exequteTask(url: url) { [weak self] (data, response, error) in
            guard let wSelf = self else { return }
            let completionHandler = wSelf.removeCompletionHandler(by: url)
            
            if let data = data, wSelf.networker.isSucccess(response: response) {
                wSelf.save(data: data, toCacheBy: url)
                completionHandler?.success?(data)
            } else if let error = error {
                completionHandler?.failure?(error)
            }
        }
    }
    
    private func removeCompletionHandler(by url: URL) -> ComplitionHandlerType? {
        var removedValue: ComplitionHandlerType?
        
        serialQueue.sync { [weak self] in
            removedValue = self?.complitionHandlers.removeValue(forKey: url)
        }
        return removedValue
    }
    
    private func save(data: Data, toCacheBy url: URL) {
        serialQueue.sync { [weak self] in
            self?.dataCache.setObject(data as NSData, forKey: url.absoluteString as NSString)
        }
    }
}
