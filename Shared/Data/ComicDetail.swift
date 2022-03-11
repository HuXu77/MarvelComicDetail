//
//  ComicDetail.swift
//  MarvelComic
//
//  Created by Mitchell Clay on 3/9/22.
//

struct ComicBaseData: Decodable {
    let code: Int?
    let status: String?
    let copyright: String?
    let attributionText: String?
    let data: ComicDataContainer?
}

struct ComicDataContainer: Decodable {
    let count: Int?
    let results: [ComicData]?
}

struct ComicData: Decodable {
    let title: String?
    let description: String?
    let thumbnail: ImageData?
}

struct ImageData: Decodable {
    let path: String?
    let `extension`: String?
}
