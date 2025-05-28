//
//  CardGameApp.swift
//  CardGame
//
//  Created by Russell Leon Bates IV on 5/28/25.
//

import SwiftUI

@main
struct CardGameApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
