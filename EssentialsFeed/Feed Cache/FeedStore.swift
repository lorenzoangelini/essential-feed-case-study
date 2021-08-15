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
    func insertItems(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionComplition)
}


public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
    
    public init(id: UUID, description: String?, location: String?, imageUrl: URL ){
        self.description = description
        self.id = id
        self.imageUrl = imageUrl
        self.location = location
    }
}
