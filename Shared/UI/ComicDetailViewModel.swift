//
//  ComicDetailViewModel.swift
//  MarvelComic
//
//  Created by Mitchell Clay on 3/11/22.
//

import SwiftUI
import Combine

@MainActor
class ComicDetailViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var title: String = "Loading..."
    @Published var description: String = "Loading..."
    @Published var image: UIImage
    
    @Published var errorMessage: String?
    @Published var error: Bool = false
    @Published var showErrorMessage: Bool = false
    
    private var dataSource: DataSource
    
    private var cancellable: Cancellable?
    
    init() {
        self.image = ComicDetailViewModel.placeholderImage()
        #if DEBUG
        if PreviewHelper.isPreviewMode() {
            dataSource = MockMarvelAPI()
            return
        }
        #endif
        #if TEST
        dataSource = MockMarvelAPI()
        return
        #endif
        dataSource = LiveMarvelAPI()
        cancellable = dataSource.isLoading.sink {
            self.loading = $0
        }
    }
    
    /**
        Load comic details from the datasource. This loads the data and image.
        - Parameter id: comic ID to load
     */
    func loadComicDetails(comicId id: Int) async {
        self.resetValuesForLoading()
        do {
            let comicData = try await dataSource.getComicDetails(comicId: id)
            guard let comicInfo = comicData.data?.results?.first else {
                throw DataError.unableToLoadJson
            }
            
            self.title = comicInfo.title ?? "No title"
            self.description = comicInfo.description ?? "No description"
            
            guard let imageData = comicInfo.thumbnail else {
                throw DataError.unableToLoadImage
            }
            guard let thumbnail = try await dataSource.getImage(from: imageData) else {
                throw DataError.unableToLoadImage
            }
            self.image = thumbnail

        } catch {
            self.errorMessage = error.localizedDescription
            self.error = true
            self.image = ComicDetailViewModel.placeholderImage()
            self.title = "Error"
            self.description = "Error"
            self.showErrorMessage = true
        }
    }
    
    private func resetValuesForLoading() {
        self.title = "Loading..."
        self.description = "Loading..."
        self.image = ComicDetailViewModel.placeholderImage()
        self.error = false
    }
    
    static private func placeholderImage() -> UIImage {
        return UIImage(named: "placeholder") ?? UIImage()
    }
}
