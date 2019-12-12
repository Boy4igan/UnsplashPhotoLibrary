import Foundation

class ULPhotoViewModel {
    private let photo: ULPhoto
    
    var imageData: Data? {
        return photo.imageData
    }
    
    init(photo: ULPhoto) {
        self.photo = photo
    }
}

