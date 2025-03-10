//
//  FCUserCoins.swift
//  French Lick Games
//
//  Created by Dias Atudinov on 10.03.2025.
//


import SwiftUI

class FCUserCoins: ObservableObject {
    static let shared = FCUserCoins()
    
    @AppStorage("coins") var storedCoins: Int = 15
    @Published var coins: Int = 15
    
    @AppStorage("score") var storedScore: Int = 0
    @Published var score: Int = 0
    
    @AppStorage("maxScore") var storedMaxScore: Int = 0
    @Published var maxScore: Int = 0
    
    init() {
        coins = storedCoins
        score = storedScore
        maxScore = storedMaxScore
    }
    
    func updateMaxScore(for score: Int) {
        self.maxScore = 0
        self.maxScore += score
        storedMaxScore = self.maxScore
    }
    
    func updateScore(for score: Int) {
        self.score += score
        storedScore = self.score
    }
    
    func updateUserCoins(for coins: Int) {
        self.coins += coins
        storedCoins = self.coins
    }
    
    func minusUserCoins(for coins: Int) {
        self.coins -= coins
        if self.coins < 0 {
            self.coins = 0
        }
        storedCoins = self.coins
        
    }
    
}