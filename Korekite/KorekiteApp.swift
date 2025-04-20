//
//  KorekiteApp.swift
//  Korekite
//
//  Created by 国米宏司 on 2025/04/20.
//

import SwiftUI

@main
struct KorekiteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
