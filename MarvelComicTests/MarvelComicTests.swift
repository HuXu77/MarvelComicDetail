//
//  MarvelComicTests.swift
//  MarvelComicTests
//
//  Created by Mitchell Clay on 3/14/22.
//

import XCTest
@testable import MarvelComic

class MarvelComicTests: XCTestCase {
    
    func testSuccessfulMockDataSource() async throws {
        let dataSource = MockMarvelAPI()
        
        let comicDetails = try await dataSource.getComicDetails(comicId: 234)
        guard let comicDetail = comicDetails.data?.results?.first else {
            XCTFail("Detail should be available")
            return
        }
        XCTAssertNotNil(comicDetail.title)
        XCTAssertNotNil(comicDetail.description)
    }
    
    func testSuccessfulMockImageLoad() async throws {
        let dataSource = MockMarvelAPI()
        
        let comicDetails = try await dataSource.getComicDetails(comicId: 234)
        guard let comicDetail = comicDetails.data?.results?.first else {
            XCTFail("Detail should be available")
            return
        }
        guard let imageData = comicDetail.thumbnail else {
            XCTFail("Image data should be there")
            return
        }
        
        let image = try await dataSource.getImage(from: imageData)
        XCTAssertNotNil(image)
    }
    
    func testFailedDataLoad() async throws {
        let dataSource = MockMarvelAPI(basePath: "nil")
        do {
            let _ = try await dataSource.getComicDetails(comicId: 1231)
        } catch DataError.unableToLoadJson {
            XCTAssert(true)
            return
        }
        
        XCTFail("Did Not Throw Error")
    }
    
    func testFailedImageLoad() async throws {
        let dataSource = MockMarvelAPI()
        let imageData = ImageData(path: nil, extension: nil)
        do {
            let _ = try await dataSource.getImage(from: imageData)
        } catch DataError.unableToLoadImage {
            XCTAssertTrue(true)
            return
        }
        
        XCTFail("Did Not Throw Error")
    }

}
