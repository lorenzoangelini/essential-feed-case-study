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
}

class LocalFeedLoader {
    
    init (store: FeedStore){}
    var deleteCachedFeedCallCount = 0
}


class CacheFeedUseTestCase: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
         _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }



}
