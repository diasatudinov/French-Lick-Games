import SwiftUI

class GameData: ObservableObject {
    @Published var stamina: CGFloat = 100.0
    let maxStamina: CGFloat = 100.0
}