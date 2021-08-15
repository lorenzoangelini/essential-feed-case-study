//
//  FeedLoader.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 09/08/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}



public protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
