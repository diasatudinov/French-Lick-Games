import SpriteKit
import SwiftUI

// MARK: - Obstacle Type

enum ObstacleType {
    case stone, tree, rivalHorse
}

func colorForObstacle(_ type: ObstacleType) -> UIColor {
    switch type {
    case .stone: return .gray
    case .tree: return .green
    case .rivalHorse: return .black
    }
}

// MARK: - RunnerGameScene

class RunnerGameScene: SKScene {
    
    // MARK: - Game Nodes and State
    var horse: SKSpriteNode!
    var lanePositions: [CGFloat] = []
    var currentLane: Int = 1 // 0, 1, 2 (middle lane)
    var isJumping = false
    var acceleration = false
    var gameOver = false
    
    var obstacles: [SKSpriteNode] = []
    
    // Speed properties (points per second)
    var baseSpeed: CGFloat = 200.0
    var lastUpdateTime: TimeInterval = 0
    
    // For swipe detection
    var initialTouchY: CGFloat?
    
    // Lane spacing – we define lanes based on scene height
    var laneCount: Int { return 3 }
    
    // Fixed horizontal position for the horse
    let horseX: CGFloat = 100
    
    // Acceleration button node
    var accelButton: SKLabelNode!
    
    // New background nodes
    var bg1: SKSpriteNode!
    var bg2: SKSpriteNode!
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        backgroundColor = .skyBlue
        
        // Set up moving background image:
        let bgTexture = SKTexture(imageNamed: "fieldFL")
        bg1 = SKSpriteNode(texture: bgTexture)
        bg1.anchorPoint = .zero
        bg1.position = .zero
        bg1.zPosition = -1  // behind other nodes
        bg1.size = self.size
        addChild(bg1)
        
        bg2 = SKSpriteNode(texture: bgTexture)
        bg2.anchorPoint = .zero
        // Place bg2 right next to bg1 (minus 1 point to avoid a gap)
        bg2.position = CGPoint(x: bg1.size.width - 1, y: 0)
        bg2.zPosition = -1
        bg2.size = self.size
        addChild(bg2)
        
        // Define lane positions (evenly spaced vertically)
        let laneHeight = size.height / CGFloat(laneCount)
        lanePositions = (0..<laneCount).map { CGFloat($0) * laneHeight + laneHeight / 2 }
        
        // Create the horse sprite
        horse = SKSpriteNode(color: .brown, size: CGSize(width: 60, height: 60))
        horse.position = CGPoint(x: horseX, y: lanePositions[currentLane])
        addChild(horse)
        
        // Create an acceleration button in the upper-right corner
        accelButton = SKLabelNode(text: "Accelerate")
        accelButton.name = "accelButton"
        accelButton.fontSize = 24
        accelButton.fontColor = .orange
        accelButton.position = CGPoint(x: size.width - 100, y: size.height - 50)
        addChild(accelButton)
        
        // Optionally, draw lane dividers
        for lane in 0..<laneCount {
            let y = lanePositions[lane]
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            let line = SKShapeNode(path: path)
            line.strokeColor = UIColor.white.withAlphaComponent(0.5)
            line.lineWidth = 2
            addChild(line)
        }
        
        lastUpdateTime = 0
        
        // Start by spawning an obstacle
        spawnObstacle()
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        if gameOver { return }
        
        // Calculate delta time
        let dt = (lastUpdateTime == 0) ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update moving background
        let backgroundSpeed = baseSpeed * 0.3  // adjust multiplier for parallax effect
        bg1.position.x -= backgroundSpeed * CGFloat(dt)
        bg2.position.x -= backgroundSpeed * CGFloat(dt)
        
        // When a background node moves completely off-screen, reposition it to the right
        if bg1.position.x <= -bg1.size.width {
            bg1.position.x = bg2.position.x + bg2.size.width - 1
        }
        if bg2.position.x <= -bg2.size.width {
            bg2.position.x = bg1.position.x + bg1.size.width - 1
        }
        
        // Determine current speed (boost if acceleration is toggled)
        let speed = acceleration ? baseSpeed * 1.5 : baseSpeed
        
        // Move obstacles left
        for obstacle in obstacles {
            obstacle.position.x -= speed * CGFloat(dt)
        }
        
        // Remove obstacles that are off-screen
        obstacles = obstacles.filter { obstacle in
            if obstacle.position.x < -50 {
                obstacle.removeFromParent()
                return false
            }
            return true
        }
        
        // Spawn a new obstacle when needed
        if obstacles.isEmpty || (obstacles.last!.position.x < size.width - 200) {
            spawnObstacle()
        }
        
        // Check collisions: if an obstacle is in the same lane and close enough (and the horse is not jumping), game over.
        for obstacle in obstacles {
            if abs(obstacle.position.x - horse.position.x) < 40 &&
               abs(obstacle.position.y - horse.position.y) < 40 {
                if !isJumping {
                    gameOver = true
                    showGameOver()
                    return
                }
            }
        }
    }
    
    // MARK: - Spawning Obstacles
    func spawnObstacle() {
        // Randomly choose an obstacle type
        let types: [ObstacleType] = [.stone, .tree, .rivalHorse]
        let type = types.randomElement()!
        let obstacle = SKSpriteNode(color: colorForObstacle(type), size: CGSize(width: 40, height: 40))
        let lane = Int.random(in: 0..<laneCount)
        obstacle.position = CGPoint(x: size.width + 50, y: lanePositions[lane])
        obstacle.name = "obstacle"
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    // MARK: - Touch Handling (for Jump and Lane Switch)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Record the initial touch Y for swipe detection.
        if let touch = touches.first {
            initialTouchY = touch.location(in: self).y
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startY = initialTouchY else { return }
        let endY = touch.location(in: self).y
        let deltaY = endY - startY
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        if nodesAtPoint.contains(where: { $0.name == "accelButton" }) {
            // Toggle acceleration if the button is tapped.
            acceleration.toggle()
            accelButton.text = acceleration ? "Normal" : "Accelerate"
            return
        }
        
        // If the vertical movement is significant, treat it as a swipe for lane switching.
        if abs(deltaY) > 20 {
            if deltaY > 0 && currentLane > 0 {
                // Swipe up: move to a higher lane
                currentLane -= 1
                let moveAction = SKAction.moveTo(y: lanePositions[currentLane], duration: 0.2)
                horse.run(moveAction)
            } else if deltaY < 0 && currentLane < laneCount - 1 {
                // Swipe down: move to a lower lane
                currentLane += 1
                let moveAction = SKAction.moveTo(y: lanePositions[currentLane], duration: 0.2)
                horse.run(moveAction)
            }
        } else {
            // Otherwise, treat as a tap for jump.
            if !isJumping {
                startJump()
            }
        }
        initialTouchY = nil
    }
    
    // MARK: - Jump Action
    func startJump() {
        isJumping = true
        let jumpHeight: CGFloat = 80
        let jumpUp = SKAction.moveBy(x: 0, y: jumpHeight, duration: 0.3)
        jumpUp.timingMode = .easeOut
        let jumpDown = SKAction.moveBy(x: 0, y: -jumpHeight, duration: 0.3)
        jumpDown.timingMode = .easeIn
        let sequence = SKAction.sequence([jumpUp, jumpDown])
        horse.run(sequence) { [weak self] in
            self?.isJumping = false
        }
    }
    
    // MARK: - Game Over
    func showGameOver() {
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(gameOverLabel)
        
        // Optionally stop all actions or present a restart button.
    }
}

struct RunnerGameContainerView: View {
    var scene: SKScene {
        let scene = RunnerGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}

struct RunnerGameContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerGameContainerView()
    }
}
