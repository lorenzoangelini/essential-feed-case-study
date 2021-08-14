//
//  CacheFeedUseTestCase.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 14/08/21.
//

import XCTest
import EssentialsFeed

class FeedStore {

    typealias DeletionComplition = (Error?) -> Void
    
   
    
    enum ReceivedMessage: Equatable {
        case deletedCacheFeedItem
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    var deletionComplition = [DeletionComplition]()
    
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
    
    func insertItems(_ items: [FeedItem], timestamp: Date){
      
       
        receivedMessages.append(.insert(items, timestamp))
    }
}

class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: ()-> Date
    
    init (store: FeedStore, currentDate: @escaping ()-> Date){
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil{
                self.store.insertItems(items, timestamp: self.currentDate())
            }
            
        }
    }
    
}


class CacheFeedUseTestCase: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store)  = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion(){
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store)  = makeSUT()
        sut.save(items)
        XCTAssertEqual(store.receivedMessages, [.deletedCacheFeedItem])
    }
    
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,  file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut  = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store,  file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store);
        
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store)  = makeSUT()
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deletedCacheFeedItem])
      
    }
    
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store)  = makeSUT(currentDate: {timestamp})
       
        sut.save(items)
        store.completeDeletionSuccessfully()
        

        XCTAssertEqual(store.receivedMessages, [.deletedCacheFeedItem, .insert(items, timestamp)])
    }
    
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "test", location: "test", imageUrl: anyURL())
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }


}
