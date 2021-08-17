//
//  CodableFeedStoreCache.swift
//  EssentialsFeedTests
//
//  Created by Lorenzo Angelini on 17/08/21.
//

import XCTest
import EssentialsFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalComplition){
        
        completion(.empty)
        
    }
    
}

class CodableFeedStoreCache: XCTestCase {
    
    func test_retrive_deliversEmptyOnEmptyCache (){
        
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Test Fail expected empty result but got \(result) instead")
            }
            
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_retrive_hasNotSideEffectOnEmptyCache (){
        
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            
            sut.retrieve { secondResult in
    
            switch (firstResult, secondResult) {
            case (.empty, .empty):
                break
            default:
                XCTFail("Test Fail expected empty result but got \(firstResult) and \(secondResult) instead")
            }
            
            
            exp.fulfill()
        }
            
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
}
