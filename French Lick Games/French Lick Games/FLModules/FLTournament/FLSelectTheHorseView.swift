import SwiftUI

enum RaceState {
    case tournament, training
}

struct FLSelectTheHorseView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var user = FLUser.shared
    @ObservedObject var viewModel: FLUpgradesViewModel
    @State var raceState: RaceState
    @State private var showTournament = false
    @State private var showTraining = false
    var body: some View {
        ZStack {
            
            VStack {
                ZStack {
                    Image(.boardBgFL)
                        .resizable()
                        .scaledToFit()
                    
                    VStack {
                        ZStack {
                            Image(.textBgFL)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 56)
                            
                            Text("Upgrades")
                                .font(.custom(FLFonts.regular.rawValue, size: 24))
                                .foregroundStyle(.white)
                                .textCase(.uppercase)
                        }
                        
                        Button {
                            if user.coins >= 150 {
                                user.minusUserCoins(for: 150)
                                
                                viewModel.buyRandomHorse()
                            } else {
                                print("No money")
                            }
                        } label: {
                            ZStack {
                                Image(user.coins >= 150 ? .btnBgFL : .btnOffIconFL)
                                    .resizable()
                                    .scaledToFit()
                                    
                                VStack(spacing: 4) {
                                    TextWithBorder(text: "Buy a new horse", font:  .custom(FLFonts.regular.rawValue, size: 10), textColor: .milk, borderColor: .black, borderWidth: 1)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 2) {
                                        Image(.coinIconFL)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 10)
                                        TextWithBorder(text: "150", font:  .custom(FLFonts.regular.rawValue, size: 8), textColor: .milk, borderColor: .black, borderWidth: 1)
                                            .textCase(.uppercase)
                                        
                                        
                                    }
                                }
                            }.frame(height: 47)
                        }
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(viewModel.boughtHorses, id: \.self) { horse in
                                horseCell(horse: horse)
                            }
                        }
                    }.padding(.top, 30).padding(.bottom)
                    
                }.padding(.vertical, 20)
            }
            
            
            VStack {
                
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(.backIconFL)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                    }
                    Spacer()
                    FLCoinsView()
                    
                }
                
                Spacer()
            }.padding()
        }.background(
            Image(.bgFL)
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
        )
        .fullScreenCover(isPresented: $showTournament) {
            FLTournamentView(upgradeVM: viewModel)
        }
        .fullScreenCover(isPresented: $showTraining) {
            RunnerGameContainerView(upgradeVM: viewModel)
        }
        
    }
    
    @ViewBuilder func horseCell(horse: Horse) -> some View {
        VStack {
            HStack {
                Image(horse.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 46)
                VStack(alignment: .leading) {
                    Text("\(horse.name)")
                        .font(.custom(FLFonts.regular.rawValue, size: 14))
                        .foregroundStyle(.milk)
                        .textCase(.uppercase)
                    Text("speed - +\(horse.speed)%")
                        .font(.custom(FLFonts.regular.rawValue, size: 10))
                        .foregroundStyle(.milk)
                        .textCase(.uppercase)
                    Text("stamina - +\(horse.stamina)%")
                        .font(.custom(FLFonts.regular.rawValue, size: 10))
                        .foregroundStyle(.milk)
                        .textCase(.uppercase)
                }
                Spacer()
                Button {
                    if user.coins >= 20 {
                        user.minusUserCoins(for: 20)
                        viewModel.upgradeHorse(for: horse)
                    }
                } label: {
                    ZStack {
                        Image(user.coins >= 20 ? .btnBgFL : .btnOffIconFL)
                            .resizable()
                        
                        
                        VStack(spacing: 0) {
                            TextWithBorder(text: "Upgrade", font:  .custom(FLFonts.regular.rawValue, size: 8), textColor: .milk, borderColor: .black, borderWidth: 1)
                                .textCase(.uppercase)
                            
                            HStack(spacing: 2) {
                                Image(.coinIconFL)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 8)
                                TextWithBorder(text: "20", font:  .custom(FLFonts.regular.rawValue, size: 6), textColor: .milk, borderColor: .black, borderWidth: 1)
                                    .textCase(.uppercase)
                                
                                
                            }
                        }
                    }.frame(width: 73, height: 37)
                }
                
            }.frame(width: 220)
            
            Button {
                    viewModel.currentHorse = horse
                if raceState == .tournament {
                    showTournament = true
                } else if raceState == .training {
                    showTraining = true
                }
            } label: {
                ZStack {
                    Image(.btnBgFL)
                        .resizable()
                    
                    TextWithBorder(text: "Select", font:  .custom(FLFonts.regular.rawValue, size: 10), textColor: .milk, borderColor: .black, borderWidth: 1)
                        .textCase(.uppercase)
                        .offset(y: -2)
                    
                    
                    
                }.frame(width: 73, height: 29)
            }
        }
    }
}

#Preview {
    FLSelectTheHorseView(viewModel: FLUpgradesViewModel(), raceState: .training)
}
