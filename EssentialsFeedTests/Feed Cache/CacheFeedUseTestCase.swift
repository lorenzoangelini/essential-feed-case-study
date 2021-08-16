//
//  CacheFeedUseTestCase.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 14/08/21.
//

import XCTest
import EssentialsFeed







class CacheFeedUseTestCase: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store)  = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion(){
        
        let (sut, store)  = makeSUT()
        sut.save(uniqueImageFeed().models){_ in}
        XCTAssertEqual(store.receivedMessages, [.deletedCacheFeedItem])
    }
    
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,  file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut  = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store,  file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store);
        
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store)  = makeSUT()
        let deletionError = anyNSError()
        sut.save(uniqueImageFeed().models){_ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deletedCacheFeedItem])
      
    }
    
    func test_save_failsOnDeletionError(){
       
        let (sut, store)  = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, completionWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
        
       
      
    }
    func test_save_failsOnInsertionError(){
     
        let (sut, store)  = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, completionWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
        
      
    }
    
    
    func test_save_succeedsOnSuccessfulInsertions(){
     
        let (sut, store)  = makeSUT()
       
        expect(sut, completionWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
        )
    }
    
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        
        let timestamp = Date()
        let (sut, store)  = makeSUT(currentDate: {timestamp})
        let feed = uniqueImageFeed()
        sut.save(feed.models){_ in}
        store.completeDeletionSuccessfully()
        

        XCTAssertEqual(store.receivedMessages, [.deletedCacheFeedItem, .insert(feed.local, timestamp)])
    }
    
    
    private func expect(_ sut: LocalFeedLoader, completionWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save([uniqueImage()]){ error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line:line)
    }
    
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated(){
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recivedResult = [LocalFeedLoader.SaveResult]()
        
        sut?.save(uniqueImageFeed().models){ recivedResult.append($0)}
        
        sut = nil
        
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(recivedResult.isEmpty)
        
        
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recivedResult = [LocalFeedLoader.SaveResult]()
        
        sut?.save(uniqueImageFeed().models){ recivedResult.append($0)}
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(recivedResult.isEmpty)
        
        
    }
    
  private  func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "test", location: "test", url: anyURL())
    }
    
private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage] ) {
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map{
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
        return (models, local)
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
  


}
