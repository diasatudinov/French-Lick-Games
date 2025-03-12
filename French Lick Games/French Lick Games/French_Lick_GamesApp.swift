//
//  French_Lick_GamesApp.swift
//  French Lick Games
//
//  Created by Dias Atudinov on 10.03.2025.
//

import SwiftUI

@main
struct French_Lick_GamesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            FLFirstView()
        }
    }
}
