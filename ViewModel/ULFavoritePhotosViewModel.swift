import Foundation

protocol ULFavoriteCollection : AnyObject {
    func addToCollection(photos: [ULPhoto])
    func saveCollection()
}

class ULFavoritePhotosViewModel: ULBasePhotosViewModel, ULFavoriteCollection {
    
    //MARK: - Public property
    
    weak var delegate: ULFavoritePhotosViewModelDelegate?
    
    //MARK: - Private property
    private var needSaveCollection = false
    private var satellite   = ULFavoritePhotosViewModelSatellite()
    private let serialQueue = DispatchQueue(label: "serialQueue.ULFavoritePhotosViewModel")
    
    
    //MARK: - Init
        
    override init() {
        super.init()
        
        satellite.loadPhotots { (photos) in
            self.appedPhotos(photos)
        }
    }
    
    //MARK: - Favorite collection
    
    func addToCollection(photos: [ULPhoto]) {
        serialQueue.async {
            let startItemIndex  = self.numberOfItems
            let lastItemIndex   = startItemIndex + photos.count - 1
            let indexPaths      = self.indexPaths(startItem: startItemIndex,
                                                  lastItem: lastItemIndex,
                                                  section: 0)
            self.appedPhotos(photos)
            self.delegate?.didReceiveItemsAt(indexPaths: indexPaths)
            self.needSaveCollection = true
        }
    }
    
    func saveCollection() {
        self.serialQueue.async {
            guard self.needSaveCollection else { return }
            
            self.satellite.savePhotos(self.allPhotos())
            self.needSaveCollection = false
        }
        
    }
    
    //MARK: - Private methods
    
    func indexPaths(startItem: Int, lastItem: Int, section: Int) -> [IndexPath] {
        return (startItem ... lastItem).map { IndexPath(item: $0, section: section) }
    }
    
}
