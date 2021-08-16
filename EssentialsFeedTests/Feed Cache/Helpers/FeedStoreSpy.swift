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
    
    var deletionComplition = [DeletionComplition]()
    var insertionComplition =  [InsertionComplition]()
    var retrievalComplition = [RetrievalComplition]()
    
    func deleteCachedFeed(completion: @escaping DeletionComplition){
      
        deletionComplition.append(completion)
        receivedMessages.append(.deletedCacheFeedItem)
    }
    func completeDeletion(with error: NSError, at index: Int = 0){
        deletionComplition[index](error)
       
        
    }
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionComplition[index](nil)
        
    }
    
    
    
    func completeInsertion(with error: NSError, at index: Int = 0){
        insertionComplition[index](error)
       
    }
    
   
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionComplition[index](nil)
        
    }
    
    func completeRetrieval(with error: NSError, at index: Int = 0){
        retrievalComplition[index](error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0){
        retrievalComplition[index](nil)
    }
    
    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionComplition){
        insertionComplition.append(completion)
       
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func retrieve(completion: @escaping RetrievalComplition) {
        retrievalComplition.append(completion)
        receivedMessages.append(.retrieve)
    }
}
