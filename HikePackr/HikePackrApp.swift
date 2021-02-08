//
//  HikePackrApp.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

@main
struct HikePackrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
