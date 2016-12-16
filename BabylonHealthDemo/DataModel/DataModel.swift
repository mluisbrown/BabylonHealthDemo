//
//  DataModel.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 06/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Result
import Argo
import Wrap

class DataModel {
    var posts: [Post]?
    var users: [Int : User]?
    
    func loadPosts(completion: @escaping (_ posts: [Post]) -> ()) {
        guard case .none = posts else {
            completion(self.posts!)
            return
        }
        
        loadCollection(from: NetworkResource.posts) { (result: Result<[Post], NetworkError>) in
            switch result {
            case .failure(let error):
                NSLog("Error loading posts from network: \(error)")
                self.posts = loadCollection(from: LocalResource.posts)
            case .success(let posts):
                self.posts = posts
            }
            
            completion(self.posts!)
        }
    }
    
    func loadUser(with userId: Int, completion: @escaping (_ user: User?) -> ()) {
        guard case .none = users else {
            completion(self.users![userId])
            return
        }
        
        loadCollection(from: NetworkResource.users) { (result: Result<[User], NetworkError>) in
            switch result {
            case .failure(let error):
                NSLog("Error loading users from network: \(error)")
                self.users = loadCollection(from: LocalResource.users).dictionary() { $0.id }
            case .success(let users):
                self.users = users.dictionary() { $0.id }
            }
            
            completion(self.users![userId])
        }
    }
    
    func loadComments(for postId: Int, completion: @escaping (_ comments: [Comment]) -> ()) {
        guard var post = posts?.filter({ $0.id == postId }).first else {
            completion([])
            return
        }

        guard case .none = post.comments else {
            completion(post.comments!)
            return
        }

        loadCollection(from: String(format: NetworkResource.comments, post.id)) { (result: Result<[Comment], NetworkError>) in
            switch result {
            case .failure(let error):
                NSLog("Error loading comments from network: \(error)")
                post.comments = []
            case .success(let comments):
                post.comments = comments
            }
            
            completion(post.comments!)
        }
    }
    
    func persist() {
        if let posts = posts {
            do {
                try write(collection: posts, to: LocalResource.posts)
            } catch {
                NSLog("Error persisting posts \(error)")
            }
        }
        
        if let users = users {
            do {
                try write(collection: Array(users.values), to: LocalResource.users)
            } catch {
                NSLog("Error persisting users \(error)")
            }
        }
    }
}

