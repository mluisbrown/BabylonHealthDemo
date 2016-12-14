//
//  PostsViewModel.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 06/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Result
import Argo
import Wrap

class PostsViewModel {
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
    
    func loadUser(for post: Post, completion: @escaping (_ user: User?) -> ()) {
        guard case .none = users else {
            completion(self.users![post.userId])
            return
        }
        
        loadCollection(from: NetworkResource.users) { (result: Result<[User], NetworkError>) in
            switch result {
            case .failure(let error):
                NSLog("Error loading users from network: \(error)")
                self.users = self.userMap(from: loadCollection(from: LocalResource.users))
            case .success(let users):
                self.users = self.userMap(from: users)
            }
            
            completion(self.users![post.userId])
        }
    }
    
    func userMap(from users: [User]) -> [Int : User] {
        var userMap = [Int: User]()
        users.forEach {
            userMap[$0.id] = $0
        }
        
        return userMap
    }
}

