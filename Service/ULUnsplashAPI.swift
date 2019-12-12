import Foundation

class ULUnsplashAPI {
    
    enum QueryItemParam: String {
        case query
        case currentPage            = "page"
        case numerOfItemsPerPage    = "per_page"
    }
    
    //MARK: - Private property
    
    private let accessKey = "f0e4295eada0094001d6828358f39ebd1fbf0346683ae376e2dfb6b1df4d69ca"
    private var rootUrlComponents: URLComponents = {
       var components = URLComponents()
        
        components.scheme   = "https"
        components.host     = "api.unsplash.com"
        
        return components
    }()
    
    private var searchPhotosUrlComponents: URLComponents {
        var urlComponents = rootUrlComponents
        
        urlComponents.path = "/search/photos"
        
        return urlComponents
    }
    
    //MARK: - Public methods
    
    func searchPhotosRequestWith(queryItems: [URLQueryItem]) -> URLRequest {
        var request = URLRequest(url: searchPhotosURLWith(queryItems: queryItems))
        
        request.allHTTPHeaderFields = ["Authorization" : "Client-ID \(accessKey)"]
        
        return request
    }
    
    //MARK: - Private methods
    
    func searchPhotosURLWith(queryItems: [URLQueryItem]) -> URL {
        var urlCompontnts = searchPhotosUrlComponents
        
        urlCompontnts.queryItems = queryItems
        
        guard let searchPhotosURL = urlCompontnts.url else {
            fatalError("failed to receive url from urlComponents: \(urlCompontnts.description)")
        }
        return searchPhotosURL
    }
}
