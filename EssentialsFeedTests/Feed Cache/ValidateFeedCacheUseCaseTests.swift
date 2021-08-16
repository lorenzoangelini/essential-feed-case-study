//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 16/08/21.
//

import XCTest
import EssentialsFeed

class ValidateFeedCacheUseCaseTests : XCTestCase {
    
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store)  = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError(){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletedCacheFeedItem])
        
        
    }
    
    
    //TODO
    func test_validateCache_doesNotdeletesCacheOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    func test_validateCache_doesNotdeletesOnLessThenSevenDaysOldCache(){
        let fixedCurrentDate = Date()
        let lessThenSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: lessThenSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    
    func test_validateCache_deletesOnSevenDaysOldCache(){
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletedCacheFeedItem])
        
        
    }
    
    func test_validateCache_deletesOnMoreTheSevenDaysOldCache(){
        let fixedCurrentDate = Date()
        let moreTheSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: moreTheSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletedCacheFeedItem])
        
        
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        
       
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    
    

    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,  file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut  = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store,  file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store);
        
    }
    

    
}
    

