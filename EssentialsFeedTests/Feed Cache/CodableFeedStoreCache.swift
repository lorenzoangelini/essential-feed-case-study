//
//  CodableFeedStoreCache.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 17/08/21.
//

import XCTest
import EssentialsFeed

class CodableFeedStore: FeedStore{
    

    
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
    
    
    func deleteCachedFeed(completion: @escaping DeletionComplition) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
                    return completion(nil)
                }

        do {
                    try FileManager.default.removeItem(at: storeURL)
                    completion(nil)
                } catch {
                    completion(error)
                }
        }
    
    func retrieve(completion: @escaping RetrievalComplition){
        guard let data = try? Data(contentsOf: storeURL) else {
             return completion(.empty)
        }
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeedCache, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
      
    }
    
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionComplition){
        
        do {
            let econder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try econder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        
        } catch {
            completion(error)
        }
        
        
         
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
    
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache(){
        
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
    
    func test_retrieve_deliversFailureOnRetrievalError(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT( storeURL: storeURL)
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
        
    }
    
    func test_retrieve_hasNoSideEffectOnFailure(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT( storeURL: storeURL)
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues(){
        let sut = makeSUT()
        let firstInsertionError = insert((uniqueImageFeed().local ,Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected feed to insert")
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed ,latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected  to override cache")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
        
    }
    
    func test_insert_deliversErrorOnInsertionError(){
        let invalidURLstore = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidURLstore)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let firstInsertionError = insert((feed  ,timestamp), to: sut)
        XCTAssertNotNil(firstInsertionError, "Expected feed to insert")


        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")

        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")

        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        expect(sut, toRetrieve: .empty)
    }
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line:line)
        return sut
         
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
    
    @discardableResult
    private func insert(_ cache: (feed:[LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error?{
        
        let exp = expectation(description: "Wait for cache retrieval")
        var insertionError: Error?
        
        sut.insertItems(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            XCTAssertNil(insertionError, "Expected feed to insert")
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
        
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve:expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line){
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { retrievedResult in
            
            switch (expectedResult, retrievedResult){
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
            
            default:
                XCTFail("Expected to retrieve \(expectedResult) got \(retrievedResult), instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
    }
    
   
}
