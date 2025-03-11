import SwiftUI
import SpriteKit

struct RunnerGameContainerView: View {
    @StateObject var user = FLUser.shared
    @Environment(\.presentationMode) var presentationMode
    @StateObject var gameData = GameData()
    @State var scene: SKScene = TrainingRunnerGameScene(size: UIScreen.main.bounds.size)

    @State private var isPause = false
    
    let fullBarWidth: CGFloat = 400
    let barHeight: CGFloat = 23
    
    var progress: CGFloat {
        // Ratio between 0 and 1
        min(max(gameData.distanceTraveled / gameData.totalDistance, 0), 1)
    }
    
    @State private var countdown: Int = 3
    
    var body: some View {
        ZStack {
            
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        isPause = true
                        gameData.gamePause = true
                    } label: {
                        Image(.pauseIconFL)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                    }.frame(width: 145)
                    Spacer()
                    
                    VStack {
                        VStack(spacing: 4) {
                           
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.appBrown)
                                    .frame(width: fullBarWidth + 7, height: barHeight + 8)
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.appOrange)
                                    .frame(width: fullBarWidth * progress, height: barHeight)
                                    .padding(.leading, 3)
                            }.cornerRadius(22)
                                
                        }
                        
                        VStack(spacing: 4) {
                            TextWithBorder(text: "stamina", font: .custom(FLFonts.regular.rawValue, size: 12), textColor: .milk, borderColor: .black, borderWidth: 1)
                                .textCase(.uppercase)
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: 208, height: 31)
                                    .cornerRadius(22)
                                    .foregroundStyle(.appBrown)
                                
                                Rectangle()
                                    .frame(width:  200 * (gameData.stamina / gameData.maxStamina), height: 25)
                                    .cornerRadius(22)
                                    .foregroundStyle(.green)
                                    .padding(.leading, 4)
                                
                            }
                        }
                    }.padding(.top)
                    Spacer()
                    
                    FLCoinsView()
                }
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        gameData.acceleration.toggle()
                    }) {
                        Image(.accelerationIconFL)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                    }
                    
                    Image(.jumpIconFL)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .allowsHitTesting(false)
                }
            }
            
            if gameData.gameWon && gameData.gameOver {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    GameStopBoardView(gameStopState: .win, firstBtnTapped: {
                        gameData.restartGame = true
                        countdown = 3
                        startCountdown()
                    }, secondBtnTapped: {presentationMode.wrappedValue.dismiss()})
                }
            } else if gameData.gameOver {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    GameStopBoardView(gameStopState: .lose, firstBtnTapped: {
                        gameData.restartGame = true
                        countdown = 3
                        startCountdown()
                        
                    }, secondBtnTapped: {presentationMode.wrappedValue.dismiss()})
                }
            }
            
            if isPause {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    GameStopBoardView(gameStopState: .pause, firstBtnTapped: {
                        isPause = false
                        gameData.gamePause = false
                        
                    }, secondBtnTapped: {presentationMode.wrappedValue.dismiss()})
                }
            }
            
            switch countdown {
            case 3:
                ZStack {
                    Image(.countdownBgFL)
                        .resizable()
                        .scaledToFit()
                    
                    Text("3")
                        .font(.custom(FLFonts.regular.rawValue, size: 96))
                        .foregroundStyle(.white)
                }.frame(height: 188)
                
            case 2:
                ZStack {
                    Image(.countdownBgFL)
                        .resizable()
                        .scaledToFit()
                    
                    Text("2")
                        .font(.custom(FLFonts.regular.rawValue, size: 96))
                        .foregroundStyle(.white)
                }.frame(height: 188)
            case 1:
                ZStack {
                    Image(.countdownBgFL)
                        .resizable()
                        .scaledToFit()
                    
                    Text("1")
                        .font(.custom(FLFonts.regular.rawValue, size: 96))
                        .foregroundStyle(.white)
                }.frame(height: 188)
            case 0:
                ZStack {
                    Image(.countdownBgFL)
                        .resizable()
                        .scaledToFit()
                    
                    Text("GO")
                        .font(.custom(FLFonts.regular.rawValue, size: 96))
                        .foregroundStyle(.white)
                }.frame(height: 188)
            default:
                Text("")
            }
            
        }.onAppear {
            scene = TrainingRunnerGameScene(size: UIScreen.main.bounds.size)
            scene.scaleMode = .resizeFill
            if let trainingScene = scene as? TrainingRunnerGameScene {
                trainingScene.gameData = gameData
            }
                
            startCountdown()
                            
        }
        .onChange(of: gameData.gameWon) { value in
            if value {
                user.updateUserCoins(for: 50)
            }
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { timer in
            if countdown >= 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                // Show "Go" for one more second, then call onComplete
                
            }
        }
    }
}

struct RunnerGameContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerGameContainerView()
    }
}
