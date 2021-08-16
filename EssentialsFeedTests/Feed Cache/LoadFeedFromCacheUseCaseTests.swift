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
    
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
