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
        expect(sut, toRetrieve: .empty)
    }
    
    func est_retrieve_hasNotSideEffectOnEmptyCache (){
        
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
       
       
    
        
    }
    
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues (){
        
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache(){
        
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
    
        insert((feed: feed, timestamp: timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
        

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
    
    
    private func insert(_ cache: (feed:[LocalFeedImage], timestamp: Date), to sut: CodableFeedStore){
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insertItems(cache.feed, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to insert")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve:expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line){
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { retrievedResult in
            
            switch (expectedResult, retrievedResult){
            case (.empty, .empty):
                break
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult) got \(retrievedResult), instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
    }
}
