import Foundation


class ULFavoritePhotosViewModelSatellite {
    
    //MARK: - Private properties
    
    private let fileName = "favoritePhotos.json"
    
    private var direcotryUrl: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    private lazy var fileUlr: URL = {
        return direcotryUrl.appendingPathComponent(fileName)
    }()
    
    //MARK: - Public methods
    
    func savePhotos(_ photos: [ULPhoto]) {
        do {
            let data = try JSONEncoder().encode(ULPhotosCollection(photos: photos))
            
            try data.write(to: fileUlr)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func loadPhotots(completionHandler:([ULPhoto])->Void) {
       guard FileManager.default.fileExists(atPath: fileUlr.path) else {
            completionHandler([])
            return
        }

        do {
            let data = try Data(contentsOf: fileUlr)
            let collection = try JSONDecoder().decode(ULPhotosCollection.self, from: data)
            
            completionHandler(collection.photos)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}

private extension ULFavoritePhotosViewModelSatellite {
    struct ULPhotosCollection: Codable {
        var photos: [ULPhoto]
    }
}
