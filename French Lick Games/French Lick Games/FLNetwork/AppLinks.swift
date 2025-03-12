import SwiftUI

class AppLinks {
    
    static let shared = AppLinks()
    
    static let winStarData = "https://sweetnemesis.xyz/get"
    
    @AppStorage("finalUrl") var finalURL: URL?
    
    
}