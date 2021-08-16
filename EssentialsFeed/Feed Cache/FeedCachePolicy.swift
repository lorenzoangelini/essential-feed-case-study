//
//  FeedCachePolicy.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 17/08/21.
//

import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init () {}
    
    private static var maxCacheInDays: Int {
        return 7
    }
    
   static func validate(_ timestamp: Date, against date: Date) -> Bool {
       
        guard let maxCachedAge = calendar.date(byAdding: .day, value: maxCacheInDays, to: timestamp) else {
            return false
        }
        return date < maxCachedAge
        
        
    }
    
    
}
