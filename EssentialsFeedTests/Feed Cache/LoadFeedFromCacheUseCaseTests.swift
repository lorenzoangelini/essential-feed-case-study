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
    
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,  file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut  = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store,  file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store);
        
    }
    
    private class  FeedStoreSpy :  FeedStore{
        

        enum ReceivedMessage: Equatable {
            case deletedCacheFeedItem
            case insert([LocalFeedImage], Date)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        var deletionComplition = [DeletionComplition]()
        var insertionComplition =  [InsertionComplition]()
        
        func deleteCachedFeed(completion: @escaping DeletionComplition){
          
            deletionComplition.append(completion)
            receivedMessages.append(.deletedCacheFeedItem)
        }
        func completeDeletion(with error: NSError, at index: Int = 0){
            deletionComplition[index](error)
           
            
        }
        func completeDeletionSuccessfully(at index: Int = 0){
            deletionComplition[index](nil)
            
        }
        
        
        
        func completeInsertion(with error: NSError, at index: Int = 0){
            insertionComplition[index](error)
           
            
        }
        
        func completeInsertionSuccessfully(at index: Int = 0){
            insertionComplition[index](nil)
            
        }
        
        func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionComplition){
            insertionComplition.append(completion)
           
            receivedMessages.append(.insert(feed, timestamp))
        }
    }

    
}