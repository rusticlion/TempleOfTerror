import SwiftUI

@main
struct DiceDelverApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .tint(Theme.gold)
        }
    }
}
