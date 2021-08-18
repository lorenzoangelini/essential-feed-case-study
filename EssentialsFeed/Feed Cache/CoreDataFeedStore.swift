//
//  CoreDataFeedStore.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 18/08/21.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
  

    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

}
