//
//  EssentialsFeedCacheIntegrationTests.swift
//  EssentialsFeedCacheIntegrationTests
//
//  Created by Lorenzo Angelini on 18/08/21.
//

import XCTest
import EssentialsFeed

class EssentialsFeedCacheIntegrationTests: XCTestCase {
    
    
    func test_load_deliversNoItemsOnEmptyCache(){
        
        let sut = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        
        sut.load {  result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [], "expected empty")
            case let .failure(error):
                XCTFail("Expect result got \(error)")
                
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }

    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL{
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    
    private func cacheDirectory() -> URL{
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    

}
