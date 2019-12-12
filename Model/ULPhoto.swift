import Foundation

struct ULPhoto : Codable {
    let width: Int
    let height: Int
    let urls: [Size.RawValue : String]
    var imageData: Data?
    
    enum Size: String {
        case raw, full, regular, small, thumb
    }
}
