//
//  FeedStore.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 15/08/21.
//

import Foundation
public protocol FeedStore {
    typealias DeletionComplition = (Error?) -> Void
    typealias InsertionComplition = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionComplition)
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionComplition)
}

