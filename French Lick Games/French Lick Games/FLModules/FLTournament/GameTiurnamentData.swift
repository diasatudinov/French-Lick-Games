import SwiftUI

class GameTiurnamentData: ObservableObject {
    @Published var stamina: CGFloat = 100.0
    let maxStamina: CGFloat = 100.0
    @Published var acceleration: Bool = false
    @Published var raceStarted: Bool = false
    @Published var gameOver = false
    @Published var gameWon = false
    
    @Published var distanceTraveled: CGFloat = 0.0
        // Total distance is fixed (for example, finishLineX - startLineX)
        let totalDistance: CGFloat = 12000.0
    
    @Published var gamePause = false {
        didSet {
            if gamePause {
                onPause?()
            } else {
                onResume?()
            }
        }
    }
    
    @Published var restartGame: Bool = false {
        didSet {
            if restartGame {
                onRestart?()
                stamina = 100.0
                acceleration = false
                raceStarted = false
                gameOver = false
                gameWon = false
                distanceTraveled = 0.0
                // Optionally reset the flag so it only fires once.
                restartGame = false
            }
        }
    }
    // A closure property that will be set by your scene.
    var onRestart: (() -> Void)?
    var onPause: (() -> Void)?
    var onResume: (() -> Void)?
    
}
