//
//  ComicDetailView.swift
//  Shared
//
//  Created by Mitchell Clay on 3/9/22.
//

import SwiftUI

struct ComicDetailView: View {
    let id: Int
    @ObservedObject var viewModel: ComicDetailViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack {
                titleView
                imageView
                descriptionView
            }.task {
                await viewModel.loadComicDetails(comicId: id)
            }.alert("Error", isPresented: $viewModel.error) {
                Button("Ok") {
                    viewModel.error = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown Error")
            }.background(Color.black)
        }.redacted(reason: viewModel.loading ? .placeholder : [])
    }
    
    private var titleView: some View {
        Text(viewModel.title)
            .font(.largeTitle)
            .padding()
    }
    
    private var descriptionView: some View {
        Text(viewModel.description)
            .font(.body)
            .padding()
    }
    
    private var imageView: some View {
        HStack {
            Spacer()
            ZStack {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            Spacer()
        }.background {
            Image(uiImage: viewModel.image)
                .resizable()
                .blur(radius: 6)
                .scaledToFill()
        }.padding()
    }
}

struct ComicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ComicDetailView(id: 92260)
            .preferredColorScheme(.dark)
    }
}

