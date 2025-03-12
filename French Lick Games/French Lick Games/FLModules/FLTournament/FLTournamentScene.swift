import SpriteKit
import SwiftUI

class FLTournamentScene: SKScene {
    
    // MARK: - Game Nodes and State
    var horse: SKSpriteNode!
    var lanePositions: [CGFloat] = []
    var currentLane: Int = 1 // 0, 1, 2 (middle lane)
    var isJumping = false
    
    var obstacles: [SKSpriteNode] = []
    
    // Speed properties (points per second)
    var baseSpeed: CGFloat = 200.0
    var lastUpdateTime: TimeInterval = 0
    
    var stamina: CGFloat = 100.0
    var upgradesVM: FLUpgradesViewModel?
    var gameData: GameTiurnamentData? {
        didSet {
            // When gameData is assigned, set its onRestart closure
            gameData?.onRestart = { [weak self] in
                self?.restartGameFunc()
            }
            
            gameData?.onPause = { [weak self] in
                self?.pauseGame()
            }
            
            gameData?.onResume = { [weak self] in
                self?.resumeGame()
            }
            
        }
    }
    
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
    
   // var raceStarted = false
    var startTime: TimeInterval? = nil
    let startLineX: CGFloat = 150    // координата линии старта
    let finishLineX: CGFloat = 700   // координата, где появится линия финиша
    var startLine: SKSpriteNode!
    var finishLine: SKSpriteNode? = nil
        
    let horseSpeed: CGFloat = 100
    var opponentHorses: [SKSpriteNode] = []
    
    var activeGameTime: TimeInterval = 0
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        startGame()
    }
    
    func startGame() {
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
        let laneHeight = (size.height  / CGFloat(laneCount)) - 15
        lanePositions = (0..<laneCount).map { CGFloat($0) * laneHeight + laneHeight / 2 }
        
        // Создаем линию старта с использованием изображения "start_line"
           startLine = SKSpriteNode(imageNamed: "start_line")
           // Задаем размер линии (ширина 5, высота = высота сцены)
           startLine.size = CGSize(width: 16, height: size.height * 4/5)
           startLine.position = CGPoint(x: startLineX, y: size.height * 1/3)
           startLine.zPosition = 4
           addChild(startLine)
        
       
        guard var upgradesVM = upgradesVM, var currentHorse = upgradesVM.currentHorse  else { return }
        // Create the horse sprite
        
        horse = SKSpriteNode(texture: SKTexture(imageNamed: "\(currentHorse.type)_horse1"))
        horse.size = CGSize(width: 130, height: 85)
        horse.position = CGPoint(x: startLineX - 50, y: lanePositions[currentLane])
        horse.zPosition = 5
        addChild(horse)
        
        
        // Create opponent horse 1 – placed in the top lane and slightly behind the player's horse.
        let opponent1 = SKSpriteNode(texture: SKTexture(imageNamed: "type3_horse1"))
        opponent1.size = CGSize(width: 130, height: 85)
        opponent1.position = CGPoint(x: startLineX - 50, y: lanePositions[0])
        opponent1.zPosition = 5
        addChild(opponent1)
        opponentHorses.append(opponent1)
        
        // Create opponent horse 2 – placed in the bottom lane and even further behind.
        let opponent2 = SKSpriteNode(texture: SKTexture(imageNamed: "type2_horse1"))
        opponent2.size = CGSize(width: 130, height: 85)
        opponent2.position = CGPoint(x: startLineX - 100, y: lanePositions[2])
        opponent2.zPosition = 5
        addChild(opponent2)
        opponentHorses.append(opponent2)
        
        var runningTextures: [SKTexture] = []
        var runningTextures1: [SKTexture] = []
        var runningTextures2: [SKTexture] = []
        
        for i in 2...13 {
            let textureName = "\(currentHorse.type)_horse\(i)"  // Make sure your images are named "horse1", "horse2", etc.
            let textureName1 = "type3_horse\(i)"
            let textureName2 = "type2_horse\(i)"
            
            let texture = SKTexture(imageNamed: textureName)
            let texture1 = SKTexture(imageNamed: textureName1)
            let texture2 = SKTexture(imageNamed: textureName2)
            
            runningTextures.append(texture)
            runningTextures1.append(texture1)
            runningTextures2.append(texture2)
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Create an animation action that cycles through the textures:
            let runningAnimation = SKAction.animate(with: runningTextures, timePerFrame: 0.07)
            let runningAnimation1 = SKAction.animate(with: runningTextures1, timePerFrame: 0.07)
            let runningAnimation2 = SKAction.animate(with: runningTextures2, timePerFrame: 0.07)
            // Repeat the animation forever:
            let runningLoop = SKAction.repeatForever(runningAnimation)
            let runningLoop1 = SKAction.repeatForever(runningAnimation1)
            let runningLoop2 = SKAction.repeatForever(runningAnimation2)
            // Run the animation on the horse node:
            
            self.horse.run(runningLoop)
            opponent1.run(runningLoop1)
            opponent2.run(runningLoop2)
        }
        
        lastUpdateTime = 0
        
        // Ждем 3 секунды до начала забега
        run(SKAction.wait(forDuration: 3)) { [weak self] in
            self?.startRace()
        }
        
        // Start by spawning an obstacle
        spawnObstacle()
    }
    
    func startRace() {
        // Начинаем забег: устанавливаем флаг и записываем время старта
        gameData?.raceStarted = true
        startTime = CACurrentMediaTime()
        
        // Анимируем постепенное исчезновение линии старта (например, за 5 секунд)
        let fadeOut = SKAction.fadeOut(withDuration: 2)
        startLine.run(fadeOut)
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        if var gameData = gameData, gameData.gameOver { return }
        
        // Calculate delta time
        let dt = (lastUpdateTime == 0) ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard var gameData = gameData, gameData.raceStarted else { return }
        
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
        
        // Если прошло 60 секунд от старта и линия финиша еще не добавлена – добавляем её
        if gameData.raceStarted && !self.isPaused {
            activeGameTime += dt
        }
        
        // Use activeGameTime to check if the finish line should be added.
        
        
        
        if finishLine == nil, activeGameTime >= 60 {
            addFinishLine()
        }
        
        if let finishLine = finishLine {
                finishLine.position.x -= baseSpeed * CGFloat(dt)
            }
        
        // Если линия финиша добавлена, проверяем пересечение
        if let finishLine = finishLine, horse.position.x >= finishLine.position.x {
            finishRace()
            
        }
        
        if gameData.acceleration {
            // При ускорении стамина уменьшается
            stamina = max(stamina - 20 * CGFloat(dt), 0)
            if stamina == 0 {
                gameData.acceleration = false
                // Можно обновить текст кнопки, если нужно
            }
        } else {
            // При обычном режиме стамина восстанавливается
            stamina = min(stamina + 10 * CGFloat(dt), 100)
        }
        // Обновляем общее состояние в GameData
        gameData.stamina = stamina
        
        // Determine current speed (boost if acceleration is toggled)
        let speed = gameData.acceleration ?? false ? baseSpeed * 1.5 : baseSpeed
        
        gameData.distanceTraveled = activeGameTime * speed
        
        // Move obstacles left
        for obstacle in obstacles {
            obstacle.position.x -= speed * CGFloat(dt)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for opponent in self.opponentHorses {
                opponent.position.x -= 100 * CGFloat(dt)
            }
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
                    gameData.gameOver = true
                    
                    return
                }
            }
        }
    }
    
    func addFinishLine() {
        // Создаем линию финиша с использованием изображения "finish_line"
            finishLine = SKSpriteNode(imageNamed: "finish_line")
        finishLine!.size = CGSize(width: 36, height: size.height * 4/5)
            finishLine!.position = CGPoint(x: finishLineX, y: size.height * 1/3)
            finishLine!.zPosition = 4
            addChild(finishLine!)
    }
    
    func finishRace() {
        gameData?.gameWon = true
        gameData?.gameOver = true
        //showGameOver()
    }
    
    // MARK: - Spawning Obstacles
    func spawnObstacle() {
        // Randomly choose an obstacle type
        let types: [ObstacleType] = [.stone, .tree, .rivalHorse]
        let type = types.randomElement()!
        
        // Select texture name and assign a custom size based on obstacle type.
        let textureName: String
        let obstacleSize: CGSize
        switch type {
        case .stone:
            textureName = "obstacle_stone"
            obstacleSize = CGSize(width: 70, height: 53)   // Stone size
        case .tree:
            textureName = "obstacle_wood"
            obstacleSize = CGSize(width: 44, height: 53)   // Tree size
        case .rivalHorse:
            textureName = "obstacle_puddle"
            obstacleSize = CGSize(width: 117, height: 53)   // Rival horse size
        }
        
        let texture = SKTexture(imageNamed: textureName)
        let obstacle = SKSpriteNode(texture: texture)
        obstacle.size = obstacleSize
        
        // Place obstacle off-screen to the right, in a random lane
        let lane = Int.random(in: 0..<laneCount)
        obstacle.position = CGPoint(x: size.width + 50, y: lanePositions[lane])
        obstacle.name = "obstacle"
        obstacle.zPosition = 5
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
        
        if abs(deltaY) > 20 {
            if deltaY > 0 {
                // Swipe up: move to an upper lane (increase lane index)
                if currentLane < laneCount - 1 {
                    currentLane += 1
                    let moveAction = SKAction.moveTo(y: lanePositions[currentLane], duration: 0.2)
                    horse.run(moveAction)
                }
            } else if deltaY < 0 {
                // Swipe down: move to a lower lane (decrease lane index)
                if currentLane > 0 {
                    currentLane -= 1
                    let moveAction = SKAction.moveTo(y: lanePositions[currentLane], duration: 0.2)
                    horse.run(moveAction)
                }
            }
        } else {
            // If the swipe distance is small, treat it as a tap for jump.
            if !isJumping, var gameData = gameData, !gameData.gameOver {
                startJump()
            }
        }
        initialTouchY = nil
    }
    
    // MARK: - Jump Action
    func startJump() {
        isJumping = true
        let jumpHeight: CGFloat = 70
        let jumpUp = SKAction.moveBy(x: 0, y: jumpHeight, duration: 0.3)
        jumpUp.timingMode = .easeOut
        let jumpDown = SKAction.moveBy(x: 0, y: -jumpHeight, duration: 0.3)
        jumpDown.timingMode = .easeIn
        let sequence = SKAction.sequence([jumpUp, jumpDown])
        horse.run(sequence) { [weak self] in
            self?.isJumping = false
        }
    }
    
    func restartGameFunc() {
        print("restartGameFunc")
        // Stop all actions and remove existing nodes if needed.
        self.removeAllActions()
        self.removeAllChildren()
        // Optionally re-run your didMove(to:) or recreate the scene.
        if let view = self.view {
            print("view = self.view")
            let newScene = FLTournamentScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            newScene.gameData = self.gameData // pass along the same GameData instance
            newScene.upgradesVM = self.upgradesVM
            view.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
    
    func pauseGame() {
        self.isPaused = true
    }
    
    func resumeGame() {
        self.lastUpdateTime = CACurrentMediaTime()
        self.isPaused = false
    }
}
