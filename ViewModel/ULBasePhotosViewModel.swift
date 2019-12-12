import Foundation

class ULBasePhotosViewModel {
    
    //MARK: - Private properties
    
    private var photos              = [ULPhoto]()
    private var serialQueue         = DispatchQueue(label: "serialQueue")
    private var photoViewModelCache = NSCache<NSIndexPath, ULPhotoViewModel>()
    private var selectedPhotos      = [IndexPath : ULPhoto]()
    
    //MARK: - Public properties
    
    var numberOfItems: Int {
        var result: Int = 0
        
        serialQueue.sync {
            result = self.photos.count
        }
        return result
    }
    
    //MARK: - Public methods
    
    func photoViewModelAt(indexPath: IndexPath) -> ULPhotoViewModel {
        if let objFromCache = photoViewModelFromCache(atIndexPath: indexPath) {
            return objFromCache
        }
        let newPhotoViewModel = ULPhotoViewModel(photo: photoAt(indexPath: indexPath))
        
        addToCache(photoViewModel: newPhotoViewModel, byIndexPath: indexPath)
        
        return newPhotoViewModel
    }
    
    func selectItem(atIndexPath indexPath: IndexPath) {
        serialQueue.async {
            self.selectedPhotos[indexPath] = self.photos[indexPath.row]
        }
    }
    
    func deselecItem(atIndexPath indexPath: IndexPath) {
        serialQueue.async {
            self.selectedPhotos.removeValue(forKey: indexPath)
        }
    }
    
    func allSelectedPhotos() -> [ULPhoto] {
        var result = [ULPhoto]()
        
        serialQueue.sync {
            result.append(contentsOf: selectedPhotos.values)
        }
        return result
    }
    
    func haveSelectedPhotos() -> Bool {
        var answer = false
        
        serialQueue.sync {
            answer = !self.selectedPhotos.isEmpty
        }
        return answer
    }
    
    func removeAllSelectedPhotos() {
        serialQueue.sync {
            self.selectedPhotos.removeAll()
        }
    }
    
    func photoSize(atIndexPath indexPath: IndexPath) -> (width: Int, height: Int) {
        let photo = photoAt(indexPath: indexPath)
        
        return (photo.width, photo.height)
    }
    
    func appedPhotos(_ photos: [ULPhoto]) {
        serialQueue.sync {
            self.photos.append(contentsOf: photos)
        }
    }
    
    func removeAllPhotos() {
        serialQueue.sync {
            self.photos.removeAll()
            self.selectedPhotos.removeAll()
        }
    }
    
    //MARK: - Protected methods
    
    func photoAt(indexPath: IndexPath) -> ULPhoto {
        var photo: ULPhoto!
        
        serialQueue.sync {
            photo = self.photos[indexPath.row]
        }
        return photo
    }
    
    func photosAt(indexPaths: [IndexPath]) -> [ULPhoto] {
        var photos = [ULPhoto]()
        
        serialQueue.sync {
            indexPaths.forEach { photos.append(self.photos[$0.row]) }
        }
        
        return photos
    }
    
    func allPhotos() -> [ULPhoto] {
        var result = [ULPhoto]()
        
        serialQueue.sync {
            result = self.photos
        }
        
        return result
    }
    
    func updatePhoto(imageData: Data, atIndexPath indexPath: IndexPath) {
        serialQueue.sync {
            self.photoViewModelCache.removeObject(forKey: indexPath as NSIndexPath)
            self.photos[indexPath.row].imageData = imageData
        }
    }
    
    //MARK: - Private methods
    
    private func photoViewModelFromCache(atIndexPath indexPath: IndexPath) -> ULPhotoViewModel? {
        var photoViewModel: ULPhotoViewModel?
        
        serialQueue.sync {
            photoViewModel = self.photoViewModelCache.object(forKey: indexPath as NSIndexPath)
        }
        return photoViewModel
    }
    
    private func addToCache(photoViewModel: ULPhotoViewModel,
                            byIndexPath indexPath: IndexPath) {
        serialQueue.sync {
            self.photoViewModelCache.setObject(photoViewModel, forKey: indexPath as NSIndexPath)
        }
    }
}
