//
//  DataModel.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 06/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

class DataModel {
    let posts = MutableProperty([Post]())
    let users = MutableProperty([Int : User]())
    let networkAvailable = MutableProperty(true)
    
    let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func loadPosts() -> SignalProducer<[Post], DataError> {
        let resource = Resource(path: "/posts", method: .GET)
        
        return network.makeRequest(resource).map {  
            self.networkAvailable.value = true
            return $0.0            
        }.on(failed: { _ in 
            self.networkAvailable.value = false             
        }).flatMapError { _ in
            read(from: LocalResource.posts)
        }.attemptMap { 
            do {
                return try .success(JSONDecoder().decode([Post].self, from: $0))
            } catch {
                return .failure(DataError.parser(error |> decodingErrorDescription))
            }
        }.on { 
            self.posts.value = $0
        }
    }
    
    func loadUsers() -> SignalProducer<[Int : User], DataError> {
        guard users.value.count == 0 else {
            return SignalProducer<[Int : User], DataError>(value: users.value)
        } 

        let resource = Resource(path: "/users", method: .GET)
        return network.makeRequest(resource).map {  
            self.networkAvailable.value = true
            return $0.0            
        }.on(failed: { _ in
            self.networkAvailable.value = false
        }).flatMapError { _ in
            read(from: LocalResource.users)            
        }.attemptMap { 
            do {
                return try .success(JSONDecoder().decode([User].self, from: $0).dictionary() { $0.id })
            } catch {
                return .failure(DataError.parser(error |> decodingErrorDescription))
            }            
        }.on { 
            self.users.value = $0
        }
    }
    
    func loadComments(for postId: Int) -> SignalProducer<[Comment], DataError> {
        guard let postInfo = posts.value.enumerated().filter( { $0.element.id == postId} ).first else {
            return SignalProducer<[Comment], DataError>(error: .data("Invalid postId: \(postId)"))
        }
        
        let post = postInfo.element
        
        if let postComments = post.comments {
            return SignalProducer<[Comment], DataError>.init(value: postComments)
        }
        
        let resource = Resource(path: "/comments", method: .GET, query: ["postId" : String(post.id)])    
        return network.makeRequest(resource).map { 
            $0.0
        }.attemptMap { 
            do {
                return try .success(JSONDecoder().decode([Comment].self, from: $0))
            } catch {
                return .failure(DataError.parser(error |> decodingErrorDescription))
            }
        }.on {
            self.posts.value[postInfo.offset].comments = $0
        }
    }
    
    func persist() {
        do {
            try write(collection: posts.value, to: LocalResource.posts)
        } catch {
            NSLog("Error persisting posts \(error)")
        }
        do {
            try write(collection: Array(users.value.values), to: LocalResource.users)
        } catch {
            NSLog("Error persisting users \(error)")
        }
    }
}

