//
//  FLUpgradesViewModel.swift
//  French Lick Games
//
//  Created by Dias Atudinov on 12.03.2025.
//

import SwiftUI

class FLUpgradesViewModel: ObservableObject {
    
    @Published var horses: [Horse] = [
        Horse(name: "Bob", image: "horseImage1", type: "type1", stamina: 5, speed: 5),
        Horse(name: "Emma", image: "horseImage2", type: "type2", stamina: 10, speed: 10),
        Horse(name: "Lola", image: "horseImage3", type: "type3", stamina: 15, speed: 15),
        Horse(name: "Happy", image: "horseImage4", type: "type4", stamina: 20, speed: 20),
        
    ]
    
    @Published var boughtHorses: [Horse] = [
        
    ]
    
    init() {
        boughtHorses.append(horses[0])
    }
    
    func upgradeHorse(for horse: Horse) {
        if let index = boughtHorses.firstIndex(where: { $0.id == horse.id }) {
            if boughtHorses[index].speed < 25 {
                boughtHorses[index].speed += 5
                boughtHorses[index].stamina += 5
            }
        }
        
        if let index = horses.firstIndex(where: { $0.id == horse.id }) {
            if horses[index].speed < 25 {
                horses[index].speed += 5
                horses[index].stamina += 5
            }
        }
    }
    
    func buyRandomHorse() {
        guard var randomHorse = horses.filter({ !boughtHorses.contains($0) }).randomElement() else { return }
        boughtHorses.append(randomHorse)
    }
    
}

struct Horse: Hashable {
    var id = UUID()
    var name: String
    let image: String
    let type: String
    var stamina: Int
    var speed: Int
}
