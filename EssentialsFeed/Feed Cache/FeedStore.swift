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
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion  = (RetrieveCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

