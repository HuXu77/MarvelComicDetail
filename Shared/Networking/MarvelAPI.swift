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
    var isLoadingData: AnyPublisher<Bool, Never> { get }
    var isLoadingImage: AnyPublisher<Bool, Never> { get }
    /**
            Load the `ComicBaseData` from a resource based on ID.
            - Parameter id: comic ID
            - Returns: `ComicBaseData`
            - Throws: Error types, specified by the implementing classes
     */
    func comicDetails(comicId id: Int) async throws -> ComicBaseData
    /**
            Load the image using `ImageData` object.
            - Parameter imageData: image data with path and extension
            - Returns: `UIImage?`
            - Throws: Error types, specified by the implementing classes
     */
    func image(from imageData: ImageData) async throws -> UIImage?
    init(basePath: String)
}

fileprivate let apiKey = "b18f9a5fda9e80a6ff6c05053b399ecb"
fileprivate let privateKey = "5f5b65c50397dd3fa35b2cb77633fb7a16028058"

class LiveMarvelAPI: DataSource {
    @Published private var loadingData: Bool
    @Published private var loadingImage: Bool
    private var basePath: String
    
    public lazy var isLoadingData: AnyPublisher<Bool, Never> = {
        $loadingData.eraseToAnyPublisher()
    }()
    public lazy var isLoadingImage: AnyPublisher<Bool, Never> = {
        $loadingImage.eraseToAnyPublisher()
    }()
    
    required init(basePath: String = "https://gateway.marvel.com/v1/public/") {
        self.loadingData = false
        self.loadingImage = false
        self.basePath = basePath
    }
    
    func comicDetails(comicId id: Int) async throws -> ComicBaseData {
        self.loadingData = true
        let comicSubPath = "comics/"
        let fullPath = "\(basePath)\(comicSubPath)\(id)?\(generateAuthString())"
        do {
            let result = try await AF.request(fullPath, method: .get).serializingDecodable(ComicBaseData.self).value
            self.loadingData = false
            return result
        } catch {
            self.loadingData = false
            throw error
        }
    }
    
    func image(from imageData: ImageData) async throws -> UIImage? {
        guard let path = imageData.path,
              let ext = imageData.extension else {
                  return nil
              }
        let fullPath = "\(path).\(ext)"
        self.loadingImage = true
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage?, Error>) in
            AF.request(fullPath, method: .get)
                .validate()
                .responseData { response in
                    self.loadingImage = false
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
    @Published private var loadingData: Bool
    @Published private var loadingImage: Bool
    private let basePath: String

    lazy var isLoadingData: AnyPublisher<Bool, Never> = {
        $loadingData.eraseToAnyPublisher()
    }()
    
    lazy var isLoadingImage: AnyPublisher<Bool, Never> = {
        $loadingImage.eraseToAnyPublisher()
    }()

    required init(basePath: String = "Mock") {
        self.loadingData = false
        self.loadingImage = false
        self.basePath = basePath
    }

    func comicDetails(comicId id: Int) async throws -> ComicBaseData {
        self.loadingData = true
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ComicBaseData, Error>) in
            guard let path = Bundle.main.url(forResource: basePath, withExtension: "json") else {
                self.loadingData = false
                continuation.resume(throwing: DataError.unableToLoadJson)
                return
            }
            do {
                let data = try Data(contentsOf: path, options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let comicData = try decoder.decode(ComicBaseData.self, from: data)
                self.loadingData = false
                continuation.resume(returning: comicData)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func image(from imageData: ImageData) async throws -> UIImage? {
        self.loadingImage = true
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage?, Error>) in
            self.loadingImage = false
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
