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
    func deleteCachedFeed(){
        deleteCachedFeedCallCount += 1
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
        let store = FeedStore()
         _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion(){
        let store = FeedStore()
        let sut  = LocalFeedLoader(store: store)
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "test", location: "test", imageUrl: anyURL())
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }


}
