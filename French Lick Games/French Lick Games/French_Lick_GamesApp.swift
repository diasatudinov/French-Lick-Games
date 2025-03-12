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
