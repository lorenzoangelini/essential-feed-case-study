//
//  FeedItemsMapper.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 11/08/21.
//

import Foundation

//Access only for this module
internal final class FeedItemMapper {
    
    private struct Root: Codable {
        let items: [Item]
        var feed: [FeedItem] {
            return items.map {
                $0.item
            }
        }
    }
    
    private struct Item: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
        
    }
    
    private static var OK_200: Int {
        return 200
    }
    
    
    

    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        
        return .success( root.feed)
        
        
        
    }
}
