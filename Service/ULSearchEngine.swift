import Foundation

protocol ULSearchEngineDelegate: AnyObject {
    func searchEngine(_ searchEngine: ULSearchEngine, didReceive photos: [ULPhoto])
    func searchEngine(_ searchEngine: ULSearchEngine, didFinishWith error: Error)
}

class ULSearchEngine {
    
    private enum SearchSate {
        case searching, waiting
    }
    
    //MARK: - Private properties
    
    private var query: String?
    private var totalPages: Int?
    private var currentPage = 1
    private var searchState = SearchSate.waiting
    
    private let unsplashAPI = ULUnsplashAPI()
    private let networker   = ULNetworker()
    private let serialQueue = DispatchQueue(label: "serialQueue.ULSearchEngine")
    
    //MARK: - Public property
    
    weak var delegate: ULSearchEngineDelegate?
    
    //MARK: - Public methods
    
    func searchPhotos(byQuery query: String) {
        serialQueue.async { [weak self] in
            self?.query = query
            self?.executeRequest()
        }
    }
    
    func loadNextPhotosPage() {
        serialQueue.async { [weak self] in
            guard self?.query != nil else { return }
            
            self?.executeRequest()
        }
    }
    
    func reset() {
        serialQueue.async {
            self.query          = nil
            self.totalPages     = nil
            self.currentPage    = 1
            self.searchState    = .waiting
        }
    }
    
    //MARK: - Private methods
    
    private func executeRequest() {
        guard searchState == .waiting else { return }
        guard currentPageLessThenTotalPages() else { return }
        let request = unsplashAPI.searchPhotosRequestWith(queryItems: searchPhotosQuetyItems())
        
        searchState = .searching
        
        networker.exequteTask(request: request) { [weak self] (data, response, error) in
            guard let wSelf = self else { return }
            
            if let data = data, wSelf.networker.isSucccess(response: response) {
                self?.didObtainSearchResponse(wSelf.pareJson(data: data))
            } else if let error = error {
                self?.didObtainError(error)
            } else {
                fatalError("no implementation")
            }
        }
    }
    
    private func didObtainSearchResponse(_ searchResponse: ULSearchResponse) {
        serialQueue.async { [weak self] in
            guard let wSelf = self else { return }
            
            wSelf.totalPages = searchResponse.totalPages
            wSelf.currentPage += 1
            wSelf.searchState = .waiting
            
            self?.delegate?.searchEngine(wSelf, didReceive: searchResponse.photos)
        }
    }
    
    private func didObtainError(_ error: Error) {
        serialQueue.async { [weak self] in
            guard let wSelf = self else { return }
            
            self?.searchState = .waiting
            self?.delegate?.searchEngine(wSelf, didFinishWith: error)
        }
    }
    
    private func pareJson(data: Data) -> ULSearchResponse {
        do {
            return try JSONDecoder().decode(ULSearchResponse.self, from: data)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func searchPhotosQuetyItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: ULUnsplashAPI.QueryItemParam.query.rawValue, value: query),
            URLQueryItem(name: ULUnsplashAPI.QueryItemParam.currentPage.rawValue, value: "\(currentPage)"),
            URLQueryItem(name: ULUnsplashAPI.QueryItemParam.numerOfItemsPerPage.rawValue, value: "30")
        ]
    }
    
    private func currentPageLessThenTotalPages() -> Bool {
        guard let totalPages = totalPages else { return true }
        if currentPage < totalPages  {
            return true
        }
        return false
    }
}
