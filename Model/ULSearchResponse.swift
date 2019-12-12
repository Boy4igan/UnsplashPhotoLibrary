import Foundation

struct ULSearchResponse : Codable {
    let totalPages: Int
    let photos: [ULPhoto]
    
    private enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case photos     = "results"
    }
}
