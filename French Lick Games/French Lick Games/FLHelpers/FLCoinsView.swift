//
//  FCCoinsView.swift
//  French Lick Games
//
//  Created by Dias Atudinov on 10.03.2025.
//


import SwiftUI

struct FCCoinsView: View {
    @StateObject var user = FCUserCoins.shared
    var body: some View {
        ZStack {
            Image(.eggsBgFC)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
            
            Text("\(user.coins)")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: 7)
        }
    }
}

#Preview {
    FCCoinsView()
}