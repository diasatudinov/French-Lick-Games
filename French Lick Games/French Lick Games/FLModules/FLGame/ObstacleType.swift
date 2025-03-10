import SwiftUI

// MARK: - Obstacle Model and Types

enum ObstacleType: String {
    case stone, tree, rivalHorse
}

struct Obstacle: Identifiable {
    let id = UUID()
    var lane: Int       // 0 (top), 1 (middle), 2 (bottom)
    var x: CGFloat      // Horizontal position
    var type: ObstacleType
}

// MARK: - Runner Game View

struct RunnerGameView: View {
    // MARK: - Game State
    @State private var horseLane: Int = 1    // Start in middle lane (0,1,2)
    @State private var isJumping: Bool = false
    @State private var jumpOffset: CGFloat = 0
    @State private var obstacles: [Obstacle] = []
    @State private var acceleration: Bool = false
    @State private var gameOver: Bool = false
    
    @State private var lastUpdateTime: Date = Date()
    @State private var timer: Timer? = nil
    @State private var gameSpeed: CGFloat = 200  // Base speed (points per second)
    
    // MARK: - Layout Constants
    let laneHeight: CGFloat = 120
    let horseSize: CGSize = CGSize(width: 60, height: 60)
    let horseX: CGFloat = 100  // Fixed horizontal position for the horse
    
    var body: some View {
        ZStack {
            // Background
            Color.green.ignoresSafeArea()
            
            // Draw lane dividers for visual reference
            ForEach(0..<3, id: \.self) { lane in
                Path { path in
                    let y = CGFloat(lane) * laneHeight + laneHeight / 2
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: y))
                }
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
            }
            
            // Obstacles (they appear as rectangles; color depends on type)
            ForEach(obstacles) { obstacle in
                let y = CGFloat(obstacle.lane) * laneHeight + laneHeight / 2
                Rectangle()
                    .fill(colorFor(obstacle.type))
                    .frame(width: 40, height: 40)
                    .position(x: obstacle.x, y: y)
            }
            
            // Horse image (you can replace with your own asset)
            // The horse’s vertical position is determined by its current lane plus any jump offset.
            let horseY = CGFloat(horseLane) * laneHeight + laneHeight / 2 + jumpOffset
            Image(systemName: "hare.fill")
                .resizable()
                .foregroundColor(.brown)
                .frame(width: horseSize.width, height: horseSize.height)
                .position(x: horseX, y: horseY)
                .animation(.easeInOut, value: horseLane)
            
            // Game Over overlay
            if gameOver {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white)
            }
            
            // Acceleration button (toggling game speed)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        acceleration.toggle()
                    }) {
                        Text(acceleration ? "Normal" : "Accelerate")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
        }
        // Tap gesture for jumping
        .gesture(
            TapGesture()
                .onEnded {
                    if !isJumping {
                        startJump()
                    }
                }
        )
        // Drag gesture for lane switching (swipe up/down)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.height < 0 {
                        // Swipe up: move to an upper lane if possible
                        if horseLane > 0 {
                            withAnimation {
                                horseLane -= 1
                            }
                        }
                    } else if value.translation.height > 0 {
                        // Swipe down: move to a lower lane if possible
                        if horseLane < 2 {
                            withAnimation {
                                horseLane += 1
                            }
                        }
                    }
                }
        )
        .onAppear {
            startGameLoop()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Helper Functions
    
    /// Starts the jump animation: moves up and then returns.
    func startJump() {
        isJumping = true
        withAnimation(.easeOut(duration: 0.3)) {
            jumpOffset = -50
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                jumpOffset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isJumping = false
            }
        }
    }
    
    /// Starts the game loop using a Timer.
    func startGameLoop() {
        lastUpdateTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            gameLoop()
        }
    }
    
    /// Main game loop: updates obstacles and checks for collisions.
    func gameLoop() {
        let currentTime = Date()
        let deltaTime = CGFloat(currentTime.timeIntervalSince(lastUpdateTime))
        lastUpdateTime = currentTime
        
        // Determine current speed (accelerated if toggled)
        let speed = acceleration ? gameSpeed * 1.5 : gameSpeed
        
        // Update obstacles: move each one leftwards based on the elapsed time.
        for i in obstacles.indices {
            obstacles[i].x -= speed * deltaTime
        }
        // Remove obstacles that have moved off screen.
        obstacles.removeAll { $0.x < -50 }
        
        // Check for collisions: if an obstacle is in the same lane and close to the horse.
        for obstacle in obstacles {
            if obstacle.lane == horseLane && abs(obstacle.x - horseX) < 40 {
                // If the horse is not sufficiently high (jumped), consider it a collision.
                if abs(jumpOffset) < 20 {
                    gameOver = true
                    timer?.invalidate()
                    return
                }
            }
        }
        
        // Spawn new obstacles if needed.
        if obstacles.isEmpty || (obstacles.last?.x ?? UIScreen.main.bounds.width) < UIScreen.main.bounds.width - 200 {
            spawnObstacle()
        }
    }
    
    /// Spawns a new obstacle at the right edge in a random lane.
    func spawnObstacle() {
        let lane = Int.random(in: 0...2)
        let types: [ObstacleType] = [.stone, .tree, .rivalHorse]
        let type = types.randomElement()!
        let newObstacle = Obstacle(lane: lane, x: UIScreen.main.bounds.width + 50, type: type)
        obstacles.append(newObstacle)
    }
    
    /// Returns a color for an obstacle based on its type.
    func colorFor(_ type: ObstacleType) -> Color {
        switch type {
        case .stone:
            return .gray
        case .tree:
            return .green
        case .rivalHorse:
            return .black
        }
    }
}

// MARK: - Preview

struct RunnerGameView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerGameView()
    }
}