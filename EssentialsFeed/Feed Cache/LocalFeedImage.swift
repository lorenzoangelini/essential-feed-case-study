//
//  LocalFeedItem.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 15/08/21.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL ){
        self.description = description
        self.id = id
        self.url = url
        self.location = location
    }
}
