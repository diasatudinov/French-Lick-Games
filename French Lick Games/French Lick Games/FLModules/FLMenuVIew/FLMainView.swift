import SwiftUI

struct FLMainMenuView: View {
    @StateObject var user = FLUser.shared
    @State private var showTournament = false
    @State private var showTraining = false
    @State private var showUpgrade = false
    
    @StateObject var upgradesVM = FLUpgradesViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                ZStack {
                    VStack(spacing: 0) {
                        Spacer()
                        ZStack {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        if user.coins >= 100 {              user.minusUserCoins(for: 100)
                                            user.openTournament = true
                                        }
                                        
                                    } label: {
                                        Image(user.coins < 100 ? .tournamentBtnOffFL: .tournamentBtnFL)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 130)
                                    }
                                    Spacer()
                                    Button {
                                        showTraining = true
                                    } label: {
                                        Image(.trainingBtnFL)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 130)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Button {
                                    showUpgrade = true
                                } label: {
                                    Image(.upgradesBtnFL)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 130)
                                }
                                
                            }
                        }
                        
                        
                    }
                    
                    
                    VStack {
                        HStack {
                            Spacer()
                            FLCoinsView()
                            
                        }
                        Spacer()
                        
                        
                    }
                    
                    
                }
                
            }.padding()
                .background(
                    Image(.bgFL)
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    
                )
                .fullScreenCover(isPresented: $user.openTournament) {
                    FLSelectTheHorseView(viewModel: upgradesVM, raceState: .tournament)
                }
                .fullScreenCover(isPresented: $showTraining) {
                    FLSelectTheHorseView(viewModel: upgradesVM, raceState: .training)
                }
                .fullScreenCover(isPresented: $showUpgrade) {
                    FLUpgradesView(viewModel: upgradesVM)
                }
            
        }
    }
}

#Preview {
    FLMainMenuView()
}
