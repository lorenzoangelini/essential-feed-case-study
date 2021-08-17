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
        
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeedCache: [LocalFeedImage] {
            return feed.map {
                $0.local
            }
        }
        
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage){
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local : LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
    }
    

    private let storeURL: URL
    
    init(storeURL: URL){
        self.storeURL = storeURL
    }
    
    
    func retrieve(completion: @escaping FeedStore.RetrievalComplition){
        guard let data = try? Data(contentsOf: storeURL) else {
             return completion(.empty)
        }
        
       let decoder = JSONDecoder()
       let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(feed: cache.localFeedCache, timestamp: cache.timestamp))
       
        
    }
    
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionComplition){
        
        let econder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! econder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
    
}

class CodableFeedStoreCache: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()

    }
    
    
    override func tearDown() {
        super.tearDown()
        undoStoreState()
        
    }
    
    
    
    func test_retrieve_deliversEmptyOnEmptyCache (){
        
        let sut = makeSUT()
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
        
        let sut = makeSUT()
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
        
        let sut = makeSUT()
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
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let storeURL = testSpecificStoreURL()

        let sut = CodableFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line:line)
        return sut
         
    }
    
    private func testSpecificStoreURL() -> URL {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
        return storeURL
    }
    
    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreState() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
