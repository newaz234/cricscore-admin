//
//  cricscoreAdminApp.swift
//  cricscoreAdmin
//
//  Created by macos on 20/4/26.
//

import SwiftUI
import FirebaseCore

@main
struct CricAdminApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            AdminContentView()
        }
    }
}
