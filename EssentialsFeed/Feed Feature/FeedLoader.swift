//
//  FeedLoader.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 09/08/21.
//

import Foundation





public protocol FeedLoader {
    
    
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
