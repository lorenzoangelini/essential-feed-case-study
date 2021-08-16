//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 16/08/21.
//

import XCTest
import EssentialsFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store)  = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval(){
        let ( sut, store)  = makeSUT()
        sut.load { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
 
    
    
    func test_load_failsOnRetrievalError(){

        let ( sut, store)  = makeSUT()
        let retrivalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrivalError), when: {
            store.completeRetrieval(with: retrivalError)
        })
       

    }
    
    func test_load_deliversNoImageOnEmptyCache(){
        let ( sut, store)  = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
        
    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache(){
       
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxDate().adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
        
    }
    
    func test_load_deliversNoImagesOnCacheExpiration(){
       
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxDate()
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        })
        
    }
    
    
    
    func test_load_deliversNoImagesOnExpiredCache(){
       
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxDate().adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        })
        
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError(){
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    func test_load_hasNoSideEffectOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    
    func test_load_doesHasNoSideEffectsOnNonExpiredCache(){
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxDate().adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.load { _ in}
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    
    func test_load_hasNoSideEffectOnCacheExpiration(){
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxDate()
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.load { _ in}
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    func test_load_hasNoSideEffectOnExpiredCache(){
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxDate().adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.load { _ in}
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResult = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResult.append($0)}
        
        sut = nil
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResult.isEmpty)
        
        
    }
    
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line){
    
        let exp = expectation(description: "Loading cache result")
      
        sut.load { recivedResult in
            switch (recivedResult, expectedResult) {
            case let (.success(recivedImages), (.success(expectedResult))):
                XCTAssertEqual(recivedImages, expectedResult, file: file, line: line)
            case let (.failure(recivedError as NSError), (.failure(expectedResult  as NSError))):
                XCTAssertEqual(recivedError, expectedResult, file: file, line: line)
            default:
                XCTFail("Expected result got \(recivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
          
        
        action()

        wait(for: [exp], timeout: 1.0)
       
        
    }
    
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,  file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut  = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store,  file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store);
        
    }
    
    



    

    
}



