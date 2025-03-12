import SwiftUI

enum GameStopState: CaseIterable {
    case pause, lose, win
}
struct GameStopBoardView: View {
    @State var gameStopState: GameStopState
    var firstBtnTapped: () -> ()
    var secondBtnTapped: () -> ()
    @State var raceState: RaceState = .training
    var body: some View {
        ZStack {
            Image(.boardBgFL)
                .resizable()
                .scaledToFit()
            VStack {
                ZStack {
                    Image(.textBgFL)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 47)
                    switch gameStopState {
                    case .pause:
                        Text("pause")
                    case .lose:
                        Text("You lose!")
                    case .win:
                        Text("You win!")
                    }
                }.font(.custom(FLFonts.regular.rawValue, size: 24))
                    .foregroundStyle(.white)
                    .textCase(.uppercase)
                
                if gameStopState == .win {
                    ZStack {
                        Image(.coinsBgFL)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                        
                        Text("+ 50")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.milk)
                            .textCase(.uppercase)
                            .offset(x: 7)
                    }
                }
                
                VStack {
                    Button {
                        firstBtnTapped()
                    } label: {
                        ZStack {
                            Image(.btnBgFL)
                                .resizable()
                                .scaledToFit()
                            VStack(spacing: -5) {
                                Text(gameStopState == .pause ? "Resume" : "Retry")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundStyle(.milk)
                                    .textCase(.uppercase)
                                if raceState == .tournament && gameStopState != .pause {
                                    HStack(spacing: 2) {
                                        Image(.coinIconFL)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 10)
                                        TextWithBorder(text: "100", font:  .custom(FLFonts.regular.rawValue, size: 10), textColor: .milk, borderColor: .black, borderWidth: 1)
                                            .textCase(.uppercase)
                                        
                                        
                                    }
                                }
                            }
                            
                        }.frame(height: 52)
                    }
                    
                    Button {
                        secondBtnTapped()
                    } label: {
                        ZStack {
                            Image(.btnBgFL)
                                .resizable()
                                .scaledToFit()
                            Text("Menu")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(.milk)
                                .textCase(.uppercase)
                            
                            
                        }.frame(height: 52)
                    }
                }
                
                Spacer()
            }.padding(.top, 30)
            
        }.frame(height: 293)
    }
}

#Preview {
    GameStopBoardView(gameStopState: .lose, firstBtnTapped: {}, secondBtnTapped: {}, raceState: .tournament)
}
