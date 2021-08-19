//
//  HTTPClient.swift
//  EssentialsFeed
//
//  Created by Lorenzo Angelini on 11/08/21.
//

import Foundation



public protocol HTTPClient {
    
    typealias Result = Swift.Result<(Data,HTTPURLResponse),Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
