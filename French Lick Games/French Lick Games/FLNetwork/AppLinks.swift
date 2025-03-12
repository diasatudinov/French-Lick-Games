import SwiftUI

class AppLinks {
    
    static let shared = AppLinks()
    
    static let winStarData = "https://google.com"
    
    @AppStorage("finalUrl") var finalURL: URL?
    
    
}
