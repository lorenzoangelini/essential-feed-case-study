//
//  CacheFeedUseTestCase.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 14/08/21.
//

import XCTest
import EssentialsFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    typealias DeletionComplition = (Error?) -> Void
    
    var insertions = [(items:[FeedItem], timestamp: Date )]()
    
    var deletionComplition = [DeletionComplition]()
    
    func deleteCachedFeed(completion: @escaping DeletionComplition){
        deleteCachedFeedCallCount += 1
        deletionComplition.append(completion)
    }
    func completeDeletion(with error: NSError, at index: Int = 0){
        deletionComplition[index](error)
       
        
    }
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionComplition[index](nil)
        
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date){
        insertCallCount += 1
        insertions.append((items, timestamp))
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
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let (_, store)  = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion(){
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store)  = makeSUT()
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
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
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessfulDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store)  = makeSUT()
       
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store)  = makeSUT(currentDate: {timestamp})
       
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
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
