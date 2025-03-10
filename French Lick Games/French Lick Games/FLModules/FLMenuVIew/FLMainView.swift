//
//  FCMainView.swift
//  French Lick Games
//
//  Created by Dias Atudinov on 10.03.2025.
//


import SwiftUI

struct FCMainView: View {
    @StateObject var user = FCUserCoins.shared
    @State private var showGames = false
    @State private var showInfo = false
    @State private var showShop = false
    @State private var showSettings = false
    
    @StateObject var settingsVM = FCSettingsViewModel()
    @StateObject var shopVM = FCShopViewModel()
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                    ZStack {
                        VStack(spacing: 0) {
                            
                            VStack(spacing: 0) {
                                Text("score")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundStyle(.white)
                                    .textCase(.uppercase)
                                ZStack {
                                    Image(.scoreBgFC)
                                        .resizable()
                                        .scaledToFit()
                                    Text(user.score == 0 ? "0000" : "\(user.score)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                        .textCase(.uppercase)
                                }.frame(height: 35)
                            }
                            Spacer()
                            ZStack {
                                
                                HStack {
                                    Spacer()
                                    Image(.logoFC)
                                        .resizable()
                                        .scaledToFit()
                                    
                                    Spacer()
                                }
                                
                                
                                VStack {
                                    Spacer()
                                    Button {
                                        showGames = true
                                    } label: {
                                        Image(.startBtnFC)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 70)
                                    }.offset(y: 20)
                                }
                            }.frame(height: 230)
                            Spacer()
                            VStack(spacing: 0) {
                                Text("max score")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .textCase(.uppercase)
                                
                                Text(user.maxScore == 0 ? "xxxx":"\(user.maxScore)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .textCase(.uppercase)
                                
                            }.offset(y: 10)
                            
                        }
                        
                        
                        VStack {
                            HStack {
                                FCCoinsView()
                                
                                Spacer()
                                Button {
                                    showSettings = true
                                } label: {
                                    Image(.settingsIconFC)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                }
                                
                            }
                            Spacer()
                            HStack {
                                
                                Button {
                                    showShop = true
                                } label: {
                                    Image(.shopIconFC)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                }
                                
                                Spacer()
                                
                                Button {
                                    showInfo = true
                                } label: {
                                    Image(.rulesIconFC)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                }
                                
                            }
                            
                        }
                            
                        
                    }
                
            }.padding()
            .background(
                Image(.bgFC)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .blur(radius: 4)
                
            )
            .onAppear {
                if settingsVM.musicEnabled {
                    FCSongsManager.shared.playBackgroundMusic()
                }
            }
            .onChange(of: settingsVM.musicEnabled) { enabled in
                if enabled {
                    FCSongsManager.shared.playBackgroundMusic()
                } else {
                    FCSongsManager.shared.stopBackgroundMusic()
                }
            }
            .fullScreenCover(isPresented: $showGames) {
                FCTrapSweeperGameView(shopVM: shopVM)
            }
            .fullScreenCover(isPresented: $showInfo) {
                FCRulesView()
            }
            .fullScreenCover(isPresented: $showShop) {
                FCShopView(shopVM: shopVM)
            }
            .fullScreenCover(isPresented: $showSettings) {
                FCSettingsView(settings: settingsVM)
                
            }
            
        }
    }
}

#Preview {
    FCMainView()
}