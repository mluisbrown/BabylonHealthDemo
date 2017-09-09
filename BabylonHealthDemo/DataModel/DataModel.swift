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
    private let posts = MutableProperty([Post]())
    private let users = MutableProperty([Int : User]())
    private let _networkAvailable = MutableProperty(true)
    let networkAvailable: Property<Bool>
    
    private let network: Network
    
    init(network: Network) {
        self.network = network
        self.networkAvailable = Property(_networkAvailable)
        createBindings()
    }
    
    private func createBindings() {
        NotificationCenter.default.reactive.notifications(forName: .UIApplicationWillResignActive)
            .observeValues { _ in
                self.persist()
        }        
    }
    
    private func makeNetworkRequest(with resource: Resource) -> SignalProducer<Data, DataError> {
        return network.makeRequest(resource).map {  
                return $0.0
            }.on(failed: { _ in
                self._networkAvailable.value = false
            }, value: { _ in
                self._networkAvailable.value = true
            })
    }
    
    func loadPosts() -> SignalProducer<[Post], DataError> {
        let resource = Resource(path: "/posts", method: .GET)                
        return makeNetworkRequest(with: resource)
            .flatMapError { _ in
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
        return makeNetworkRequest(with: resource)
            .flatMapError { _ in
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
        return makeNetworkRequest(with: resource)
            .attemptMap {
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

