//
//  RemoteFeedItem.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 15/08/21.
//

import Foundation


internal struct RemoteFeedItem: Codable {
    internal  let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
