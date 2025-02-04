//
//  MemoCardsApp.swift
//  MemoCards
//
//  Created by Saydulayev on 25.01.25.
//

import SwiftUI
import SwiftData

@main
struct MemoCardsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Card.self)
    }
}
