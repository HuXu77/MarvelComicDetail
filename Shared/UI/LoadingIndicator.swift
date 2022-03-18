//
//  LoadingIndicator.swift
//  MarvelComic (iOS)
//
//  Created by Mitchell Clay on 3/17/22.
//

import Foundation
import SwiftUI

struct LoadingIndicator: View {
    
    @State private var loadingIndicatorState: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(.systemGray5), lineWidth: 3)
                .frame(width: 250, height: 3)

            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 30, height: 3)
                .offset(x: loadingIndicatorState ? 110 : -110)
                .animation(Animation.easeInOut(duration: 2).repeatForever(), value: loadingIndicatorState)
        }.onAppear {
            loadingIndicatorState.toggle()
        }
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Empty View")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Loading...")
                            LoadingIndicator()
                        }
                    }
                }.navigationBarTitleDisplayMode(.inline)
        }.preferredColorScheme(.dark)
    }
}
