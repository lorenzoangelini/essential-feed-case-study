//
//  EssentialsFeedCacheIntegrationTests.swift
//  EssentialsFeedCacheIntegrationTests
//
//  Created by Lorenzo Angelini on 18/08/21.
//

import XCTest
import EssentialsFeed

class EssentialsFeedCacheIntegrationTests: XCTestCase {
    
    override  func tearDown() {
        super.tearDown()
        undoStoreSideEffect()
       
    }
    
    override func setUp() {
         super.setUp()
        setUpEmptyStoreTest()
    }
    
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
    func test_load_deliversItemsSavedOnASeparatedInstance(){
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Wait for completion")
        
        sutToPerformSave.save(feed) { saveError in
            
            XCTAssertNil(saveError, "Expected to save successfully")
            saveExp.fulfill()
            
        }
        
        wait(for: [saveExp], timeout: 1.0)
        
        
        let loadExp = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { result in
            
            switch result  {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, feed)
            case let .failure(error):
                XCTFail("Expect successful but got \(result)")
            }
            
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
        
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
    
    private func undoStoreSideEffect() {
        deleteStoreArtifacts()
    }
    
    private func setUpEmptyStoreTest() {
        deleteStoreArtifacts()
    }
    
    
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
