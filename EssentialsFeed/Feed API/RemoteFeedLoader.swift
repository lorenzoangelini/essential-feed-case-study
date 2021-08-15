//
//  RemoteFeedLoader.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 10/08/21.
//

import Foundation


public final class RemoteFeedLoader: FeedLoader {
  
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    

    private let client: HTTPClient
    private let url: URL
    
    public init(client: HTTPClient, url: URL){
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping(Result)-> Void){
        client.get(from: url){[weak self] result in
            guard self != nil else{
                return
            }
            switch result {
            case let .success(data, response):
                
                completion(RemoteFeedLoader.map(data, from: response))
                
               
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
           let items = try FeedItemMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
        
    }
}


private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map{
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        }
    }
}






