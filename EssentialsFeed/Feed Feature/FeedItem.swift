//
//  FeedItem.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 09/08/21.
//

import Foundation

public struct FeedItem: Equatable {
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
