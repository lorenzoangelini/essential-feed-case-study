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
                completion(FeedItemMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    
    
    
}







