//
//  ComicDetailViewModel.swift
//  MarvelComic
//
//  Created by Mitchell Clay on 3/11/22.
//

import SwiftUI
import Combine

class ComicDetailViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var title: String = "Loading..."
    @Published var description: String = "Loading..."
    @Published var image: UIImage
    
    @Published var errorMessage: String?
    @Published var error: Bool = false
    @Published var showErrorMessage: Bool = false
    
    private var dataSource: DataSource
    
    private var task: Task<Void, Never>?
    
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
        cancellable = dataSource.isLoadingData.combineLatest(dataSource.isLoadingImage)
            .receive(on: RunLoop.main)
            .sink {
                self.loading = $0.0 || $0.1
            }
    }
    
    deinit {
        task?.cancel()
        cancellable = nil
    }
    
    /**
        Load comic details from the datasource. This loads the data and image.
        - Parameter id: comic ID to load
     */
    func loadComicDetails(comicId id: Int) {
        self.resetValuesForLoading()
        runLoadingTask(comicId: id)
    }
    
    private func runLoadingTask(comicId id: Int) {
        self.task = Task {
            do {
                let comicData = try await dataSource.comicDetails(comicId: id)
                guard let comicInfo = comicData.data?.results?.first else {
                    throw DataError.unableToLoadJson
                }
                
                await updateTitleAndDescription(comicData: comicInfo)
                try await updateImage(thumbnail: comicInfo.thumbnail)
            } catch {
                await updateErrorState(error: error)
            }
        }
    }
    
    private func updateImage(thumbnail: ImageData?) async throws {
        guard let imageData = thumbnail else {
            throw DataError.unableToLoadImage
        }
        
        guard let thumbnail = try await dataSource.image(from: imageData) else {
            throw DataError.unableToLoadImage
        }
        await updateImage(image: thumbnail)
    }
    
    @MainActor
    private func updateTitleAndDescription(comicData: ComicData) {
        self.title = comicData.title ?? "No title"
        if let description = comicData.description,
           !description.isEmpty {
            self.description = description
        } else {
            self.description = "No description"
        }
    }
    
    @MainActor
    private func updateImage(image: UIImage) {
        self.image = image
    }
    
    @MainActor
    func updateErrorState(error: Error) {
        self.errorMessage = error.localizedDescription
        self.error = true
        self.image = ComicDetailViewModel.placeholderImage()
        self.title = "Error"
        self.description = "Error"
        self.showErrorMessage = true
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
