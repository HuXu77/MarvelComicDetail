//
//  MarvelAPI.swift
//  MarvelComic
//
//  Created by Mitchell Clay on 3/9/22.
//

import UIKit
import CryptoKit
import Alamofire
import SwiftUI
import Combine

protocol DataSource {
    var isLoading: AnyPublisher<Bool, Never> { get }
    /**
            Load the `ComicBaseData` from a resource based on ID.
            - Parameter id: comic ID
            - Returns: `ComicBaseData`
            - Throws: Error types, specified by the implementing classes
     */
    func getComicDetails(comicId id: Int) async throws -> ComicBaseData
    /**
            Load the image using `ImageData` object.
            - Parameter imageData: image data with path and extension
            - Returns: `UIImage?`
            - Throws: Error types, specified by the implementing classes
     */
    func getImage(from imageData: ImageData) async throws -> UIImage?
    init(basePath: String)
}

fileprivate let apiKey = "b18f9a5fda9e80a6ff6c05053b399ecb"
fileprivate let privateKey = "5f5b65c50397dd3fa35b2cb77633fb7a16028058"

class LiveMarvelAPI: DataSource {
    @Published private var loading: Bool
    private var basePath: String
    
    public lazy var isLoading: AnyPublisher<Bool, Never> = {
        $loading.eraseToAnyPublisher()
    }()
    
    required init(basePath: String = "https://gateway.marvel.com/v1/public/") {
        self.loading = false
        self.basePath = basePath
    }
    
    func getComicDetails(comicId id: Int) async throws -> ComicBaseData {
        self.loading = true
        let comicSubPath = "comics/"
        let fullPath = "\(basePath)\(comicSubPath)\(id)?\(generateAuthString())"
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ComicBaseData, Error>) in
            AF.request(fullPath, method: .get)
                .validate()
                .responseDecodable(of: ComicBaseData.self) { [unowned self] (response) in
                    self.loading = false
                if let result = response.value {
                    continuation.resume(returning: result)
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
    func getImage(from imageData: ImageData) async throws -> UIImage? {
        guard let path = imageData.path,
              let ext = imageData.extension else {
                  return nil
              }
        let fullPath = "\(path).\(ext)"
        self.loading = true
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage?, Error>) in
            AF.request(fullPath, method: .get)
                .validate()
                .responseData { response in
                    self.loading = false
                    if let result = response.value {
                        let image = UIImage(data: result)
                        continuation.resume(returning: image)
                        return
                    }
                    if let error = response.error {
                        continuation.resume(throwing: error)
                        return
                    }
                }
        }
    }
    
    private func generateAuthString() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let prehashString = "\(timestamp)\(privateKey)\(apiKey)"
        let hash = Insecure.MD5.hash(data: prehashString.data(using: .utf8) ?? Data())
        let hashString = hash.map { String(format: "%02hhx", $0 )}.joined()
        
        let authString = "ts=\(timestamp)&apikey=\(apiKey)&hash=\(hashString)"
        return authString
    }
}

#if DEBUG || TEST
class MockMarvelAPI: DataSource {
    @Published private var loading: Bool
    private let basePath: String

    lazy var isLoading: AnyPublisher<Bool, Never> = {
        $loading.eraseToAnyPublisher()
    }()

    required init(basePath: String = "Mock") {
        self.loading = false
        self.basePath = basePath
    }

    func getComicDetails(comicId id: Int) async throws -> ComicBaseData {
        self.loading = true
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ComicBaseData, Error>) in
            guard let path = Bundle.main.url(forResource: basePath, withExtension: "json") else {
                self.loading = false
                continuation.resume(throwing: DataError.unableToLoadJson)
                return
            }
            do {
                let data = try Data(contentsOf: path, options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let comicData = try decoder.decode(ComicBaseData.self, from: data)
                self.loading = false
                continuation.resume(returning: comicData)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func getImage(from imageData: ImageData) async throws -> UIImage? {
        self.loading = true
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage?, Error>) in
            self.loading = false
            guard let path = imageData.path else {
                continuation.resume(throwing: DataError.unableToLoadImage)
                return
            }
            let image = UIImage(named: path)
            continuation.resume(returning: image)
        }
    }
}
#endif

enum DataError: Error {
    case unableToLoadJson
    case unableToLoadImage
}
