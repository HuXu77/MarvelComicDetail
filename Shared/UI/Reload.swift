//
//  Reload.swift
//  MarvelComic (iOS)
//
//  Created by Mitchell Clay on 3/16/22.
//

import SwiftUI

struct ReloadView: View {
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }.foregroundColor(.red)
    }
}
