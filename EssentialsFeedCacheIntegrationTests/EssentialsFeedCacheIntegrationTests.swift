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
        expect(sut, toLoad: [])
        
        
    }
    func test_load_deliversItemsSavedOnASeparatedInstance(){
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(sutToPerformSave, toSave: feed)
        
        expect(sutToPerformLoad, toLoad: feed)
        
    }
    
    func test_save_overrideItemsSavedOnASeparatedInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(sutToPerformFirstSave, toSave: firstFeed)
        save(sutToPerformLastSave, toSave:  latestFeed)
        expect(sutToPerformLoad, toLoad: latestFeed)
        
        
        
        
        
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
    
    
    private func save(_ sut: LocalFeedLoader, toSave feedToSave: [FeedImage], file: StaticString = #file, line: UInt = #line){
        
        let exp = expectation(description: "Wait to load insert")
        sut.save(feedToSave){ saveError in
            
            XCTAssertNil(saveError, "Expect to save successfully")
            
            exp.fulfill()
            
        }
        
        wait(for: [exp], timeout: 1.0)
        
        
        
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expecetedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line){
        
        
        let exp = expectation(description: "Wait to complete load")
        
        sut.load { result in
            
            switch result  {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expecetedFeed, file: file, line: line)
            case let .failure(error):
                XCTFail("Expect result got \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        
    }

}
