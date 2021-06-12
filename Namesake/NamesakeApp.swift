//
//  NamesakeApp.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI

@main
struct NamesakeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
