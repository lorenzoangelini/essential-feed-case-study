//
//  FeedStore.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 15/08/21.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case failure(Error)
    case found(feed:[LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionComplition = (Error?) -> Void
    typealias InsertionComplition = (Error?) -> Void
    typealias RetrievalComplition  = (RetrieveCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionComplition)
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionComplition)
    func retrieve(completion: @escaping RetrievalComplition)
}

