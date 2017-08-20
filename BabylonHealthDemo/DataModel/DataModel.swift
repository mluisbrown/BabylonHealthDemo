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

struct DataModel {
    let posts = MutableProperty([Post]())
    let users = MutableProperty([Int : User]())
    let user = MutableProperty<User?>(nil)
    let comments = MutableProperty([Comment]())
    
    let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func loadPosts() {
        let resource = Resource(path: "/posts", method: .GET)
        posts <~ network.makeRequest(resource).map { (value) -> [Post] in            
            let (data, _) = value
            do {
                return try JSONDecoder().decode([Post].self, from: data)
            } catch {
                return []
            }
        }.flatMapError { _ in
            SignalProducer<[Post], NoError>.empty
        }
    }
    
    func loadUser(with userId: Int) {
        guard users.value.count == 0 else {
            user.value = users.value[userId]
            return
        }

        let resource = Resource(path: "/users", method: .GET)
        network.makeRequest(resource).map { (value) -> [Int : User] in            
            let (data, _) = value
            do {
                return try JSONDecoder().decode([User].self, from: data).dictionary() { $0.id }
            } catch {
                return [:]
            }
        }.flatMapError { _ in
            SignalProducer<[Int: User], NoError>.empty
        }.startWithValues {
            self.users.value = $0
            self.user.value = self.users.value[userId]
        }
    }
    
    func loadComments(for postId: Int) {
        guard let postInfo = posts.value.enumerated().filter({ $0.element.id == postId} ).first else {
            comments.value = []
            return
        }
        
        let post = postInfo.element
        
        if let postComments = post.comments {
            comments.value = postComments
            return
        }
        
        let resource = Resource(path: "/comments", method: .GET, query: ["postId" : String(post.id)])    
        network.makeRequest(resource).map { (value) -> [Comment] in
            let (data, _) = value
            do {
                return try JSONDecoder().decode([Comment].self, from: data)
            } catch {
                return []
            }            
        }.flatMapError { _ in
                SignalProducer<[Comment], NoError>.empty
        }.startWithValues {
            self.comments.value = $0
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

