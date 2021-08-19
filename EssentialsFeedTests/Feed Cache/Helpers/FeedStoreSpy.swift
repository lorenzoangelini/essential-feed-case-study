//
//  FeedStoreSpy.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 16/08/21.
//

import Foundation
import EssentialsFeed

class FeedStoreSpy :  FeedStore{
   
 
    

    enum ReceivedMessage: Equatable {
        case deletedCacheFeedItem
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    var deletionComplition = [DeletionCompletion]()
    var insertionComplition =  [InsertionCompletion]()
    var retrievalComplition = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion){
      
        deletionComplition.append(completion)
        receivedMessages.append(.deletedCacheFeedItem)
    }
    func completeDeletion(with error: NSError, at index: Int = 0){
        deletionComplition[index](.failure(error))
       
        
    }
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionComplition[index](.success(()))
        
    }
    
    
    
    func completeInsertion(with error: NSError, at index: Int = 0){
        insertionComplition[index](.failure(error))
       
    }
    
   
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionComplition[index](.success(()))
        
    }
    
   
    
    func completeRetrievalWithEmptyCache(at index: Int = 0){
        retrievalComplition[index](.success(.none))
    }
    
    
    func completeRetrieval(with error: Error, at index: Int = 0){
        retrievalComplition[index](.failure(error))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date,   at index: Int = 0){
        retrievalComplition[index](.success(.some(CachedFeed( feed: feed, timestamp: timestamp))))
    }
    
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion){
        insertionComplition.append(completion)
       
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalComplition.append(completion)
        receivedMessages.append(.retrieve)
    }
}
