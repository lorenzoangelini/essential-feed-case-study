//
//  CodableFeedStoreCache.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 17/08/21.
//

import XCTest
import EssentialsFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        
        let feed: [LocalFeedImage]
        let timestamp: Date
        
    }
    
    
    
    private let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    func retrieve(completion: @escaping FeedStore.RetrievalComplition){
        guard let data = try? Data(contentsOf: storeUrl) else {
             return completion(.empty)
        }
        
       let decoder = JSONDecoder()
       let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
       
        
    }
    
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionComplition){
        
        let econder = JSONEncoder()
        let encoded = try! econder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeUrl)
        
        completion(nil)
    }
    
}

class CodableFeedStoreCache: XCTestCase {
    
    
    override  func setUp() {
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeUrl)

    }
    
    
    override func tearDown() {
        super.tearDown()
        
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeUrl)
        
    }
    
    
    
    func test_retrieve_deliversEmptyOnEmptyCache (){
        
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Test Fail expected empty result but got \(result) instead")
            }
            
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func est_retrieve_hasNotSideEffectOnEmptyCache (){
        
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            
            sut.retrieve { secondResult in
    
            switch (firstResult, secondResult) {
            case (.empty, .empty):
                break
            default:
                XCTFail("Test Fail expected empty result but got \(firstResult) and \(secondResult) instead")
            }
            
            
            exp.fulfill()
        }
            
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues (){
        
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        sut.insertItems(feed, timestamp: timestamp) { insertionError in
            
            sut.retrieve { retrieveResult in
    
            switch retrieveResult {
            case let .found(retrievedFeed, retrievedTimestamp):
                XCTAssertEqual(retrievedFeed, feed)
                XCTAssertEqual(retrievedTimestamp, timestamp)
            default:
                XCTFail("Test Fail expected empty result but got  instead")
            }
            
            
            exp.fulfill()
        }
            
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
}
