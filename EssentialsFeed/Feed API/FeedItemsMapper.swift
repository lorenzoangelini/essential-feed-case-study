//
//  FeedItemsMapper.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 11/08/21.
//

import Foundation



internal struct RemoteFeedItem: Codable {
    internal  let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

//Access only for this module
internal final class FeedItemMapper {
    
    private struct Root: Codable {
        let items: [RemoteFeedItem]
       
    }
    
 
    
    private static var OK_200: Int {
        return 200
    }
    
    
    

    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        
        return root.items
        
        
        
    }
}
