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
    
    func test_load_deliversCachedImagesOnLessThenSevenDaysOldCache(){
       
        let fixedCurrentDate = Date()
        let lessThenSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timestamp: lessThenSevenDaysOldTimestamp)
        })
        
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache(){
       
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        })
        
    }
    
    
    
    func test_load_deliversNoImagesOnMoreSevenDaysOldCache(){
       
        let fixedCurrentDate = Date()
        let moreThensevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: moreThensevenDaysOldTimestamp)
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
    
    
    func test_load_doesHasNoSideEffectsOnLessThenSevenDaysOldCache(){
        let fixedCurrentDate = Date()
        let lessThenSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.load { _ in}
        store.completeRetrieval(with: feed.local, timestamp: lessThenSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
        
    }
    
    
    func test_load_deletesCacheOnSevenDaysOldCache(){
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.load { _ in}
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletedCacheFeedItem])
        
        
    }
    
    func test_load_deletesCacheOnMoreTheSevenDaysOldCache(){
        let fixedCurrentDate = Date()
        let moreTheSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        let ( sut, store)  = makeSUT( currentDate: {  fixedCurrentDate })
        
        sut.load { _ in}
        store.completeRetrieval(with: feed.local, timestamp: moreTheSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletedCacheFeedItem])
        
        
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



