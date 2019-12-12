import Foundation

@objc protocol ULPhotosViewModelDelegate: AnyObject {
    @objc optional func willStartFetchPhotos()
    func didReceiveNewPhotos(atIndexPaths indexPaths: [IndexPath])
    func didFinishLoadingPhotos(withError error: Error)
    func didUpdatePhotoViewModelAt(indexPath: IndexPath)
    func didRemoveAllPhotos()
}

class ULPhotosViewModel: ULBasePhotosViewModel, ULSearchEngineDelegate {
    
    //MARK: - Public property
    
    weak var delegate: ULPhotosViewModelDelegate?
    weak var favoriteCollection: ULFavoriteCollection?
    
    //MARK: - Private properties
    
    private let searchEngine        = ULSearchEngine()
    private let networkDataFetcher  = ULNetworkDataFetcher()
    private let serialQueue = DispatchQueue(label: "serialQueue.ULPhotosViewModel")
    
    //MARK: - Init
    
    override init() {
        super.init()
        
        searchEngine.delegate = self
    }
    
    //MARK: - Override methods
    
    override func photoViewModelAt(indexPath: IndexPath) -> ULPhotoViewModel {
        let viewModel = super.photoViewModelAt(indexPath: indexPath)
        
        ifNeedLoadImageDataForPhotoAt(indexPath: indexPath)
        
        return viewModel
    }
    
    override func updatePhoto(imageData: Data, atIndexPath indexPath: IndexPath) {
        super.updatePhoto(imageData: imageData, atIndexPath: indexPath)
        delegate?.didUpdatePhotoViewModelAt(indexPath: indexPath)
    }
    
    override func removeAllPhotos() {
        super.removeAllPhotos()
        delegate?.didRemoveAllPhotos()
    }
    
    //MARK: - Public methods
    
    func fetchPhotos(by query: String) {
        delegate?.willStartFetchPhotos?()
        searchEngine.searchPhotos(byQuery: query)
    }
    
    func loadNextPhotosPage() {
        delegate?.willStartFetchPhotos?()
        searchEngine.loadNextPhotosPage()
    }
    
    func cancelReceivingPhotos() {
        searchEngine.reset()
    }
    
    func prefetchItemsAt(indexPaths: [IndexPath]) {
        networkDataFetcher.asyncPrefechDataBy(urls: photosUrlAt(indexPaths: indexPaths))
    }
    
    func cancelPrefetchingItemsAt(indexPaths: [IndexPath]) {
        let photoURLs = photosUrlAt(indexPaths: indexPaths)
        
        networkDataFetcher.pauseDataPrefetchingBy(urls: photoURLs)
    }
    
    func moveSelectedPhotosToFavoriteCollections() {
        favoriteCollection?.addToCollection(photos: allSelectedPhotos())
        removeAllSelectedPhotos()
    }
    
    //MARK: - Search engine delegate
    
    func searchEngine(_ searchEngine: ULSearchEngine, didReceive photos: [ULPhoto]) {
        serialQueue.async {
            guard photos.count != 0 else { return }
            let indexPaths = self.indexPaths(startItem: self.numberOfItems,
                                             lastItem: self.numberOfItems + photos.count - 1,
                                             section: 0)
            
            super.appedPhotos(photos)
            self.delegate?.didReceiveNewPhotos(atIndexPaths: indexPaths)
        }
    }
    
    func searchEngine(_ searchEngine: ULSearchEngine, didFinishWith error: Error) {
        self.delegate?.didFinishLoadingPhotos(withError: error)
    }
    
    //MARK: - Private methods
    
    private func ifNeedLoadImageDataForPhotoAt(indexPath: IndexPath) {
        let photo = photoAt(indexPath: indexPath)
        
        if photo.imageData == nil {
            loadImageDataBy(url: photoURL(photo: photo), forItemAtIndexPath: indexPath)
        }
    }
    
    private func loadImageDataBy(url: URL, forItemAtIndexPath indexPath: IndexPath) {
        networkDataFetcher.asyncFetchData(by: url, successBlock: { (data) in
            self.updatePhoto(imageData: data, atIndexPath: indexPath)
        })
    }
    
    private func photoURL(photo: ULPhoto) -> URL {
        let key = ULPhoto.Size.thumb.rawValue
        guard let urlString = photo.urls[key] else { fatalError("Photo.urls not value by key: \(key)") }
        guard let url = URL(string: urlString) else { fatalError("Failed to receive url from urlString: \(urlString)") }
        
        return url
    }
    
    private func photosUrlAt(indexPaths: [IndexPath]) -> [URL] {
        let photos = photosAt(indexPaths: indexPaths)
        
        return photos.map { photoURL(photo: $0) }
    }
    
    private func indexPaths(startItem: Int, lastItem: Int, section: Int) -> [IndexPath] {
        return (startItem ... lastItem).map { IndexPath(item: $0, section: section) }
    }
}
