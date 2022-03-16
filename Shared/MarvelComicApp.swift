//
//  MarvelComicApp.swift
//  Shared
//
//  Created by Mitchell Clay on 3/9/22.
//

import SwiftUI

@main
struct MarvelComicApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ComicDetailView(id: 92260)
            }.preferredColorScheme(.dark)
        }
    }
}
