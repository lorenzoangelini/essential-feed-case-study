//
//  CodableFeedStore.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 17/08/21.
//

import Foundation

public class CodableFeedStore: FeedStore{
    
    private struct Cache: Codable {
        
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeedCache: [LocalFeedImage] {
            return feed.map {
                $0.local
            }
        }
        
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage){
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local : LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
    }
    

   public let storeURL: URL
    
   public init(storeURL: URL){
        self.storeURL = storeURL
    }
    
    
   public func deleteCachedFeed(completion: @escaping DeletionComplition) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
                    return completion(nil)
                }

        do {
                    try FileManager.default.removeItem(at: storeURL)
                    completion(nil)
                } catch {
                    completion(error)
                }
        }
    
   public func retrieve(completion: @escaping RetrievalComplition){
        guard let data = try? Data(contentsOf: storeURL) else {
             return completion(.empty)
        }
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeedCache, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
      
    }
    
   public func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionComplition){
        
        do {
            let econder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try econder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        
        } catch {
            completion(error)
        }
        
        
         
    }
    
}
