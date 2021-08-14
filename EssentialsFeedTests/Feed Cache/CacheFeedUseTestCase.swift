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
    func deleteCachedFeed(){
        deleteCachedFeedCallCount += 1
    }
    func completeDeletion(with error: NSError, at index: Int = 0){
        
    }
}

class LocalFeedLoader {
    
    private let store: FeedStore
    
    init (store: FeedStore){
        
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
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
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut  = LocalFeedLoader(store: store)
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
