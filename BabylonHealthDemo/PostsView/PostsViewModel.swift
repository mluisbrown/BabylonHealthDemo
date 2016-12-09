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

class PostsViewModel {
    struct UrlString {
        private init() {}
        static let posts = "http://jsonplaceholder.typicode.com/posts"
        static let users = "http://jsonplaceholder.typicode.com/users"
        static let comments = "http://jsonplaceholder.typicode.com/comments?postId="
    }
    
    enum PostError: Error {
        case userNotFound
        case abc
    }
    
    private let httpOk = 200
    
    private let localStorageURL: URL = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        let path = URL(fileURLWithPath: documentsDirectory, isDirectory: true).appendingPathComponent("posts.plist")

        return path
    }()
    
    var posts: [Post]?
    var users: [Int : User]?
    
    func loadPosts(completion: @escaping (_ posts: [Post]) -> ()) {
        guard case .none = posts else {
            completion(self.posts!)
            return
        }
        
        loadCollectionFrom(urlString: UrlString.posts) { (result: Result<[Post], AnyError>) in
            switch result {
            case .failure(let error):
                NSLog("Error loading posts from network: \(error)")
                self.posts = self.loadPostsFromLocalStorage()
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
        
        loadCollectionFrom(urlString: UrlString.users) { (result: Result<[User], AnyError>) in
            switch result {
            case .failure(let error):
                NSLog("Error loading users from network: \(error)")
                self.users = nil // self.loadPostsFromLocalStorage()
            case .success(let users):
                
                self.users = users.reduce([Int: User]()) { (userMap, user) -> [Int: User] in
                    var newMap = userMap
                    newMap[user.id] = user
                    return newMap
                }
                
                
                
                self.users = [Int: User]()
                users.forEach {
                    self.users![$0.id] = $0
                }
                
            }
            
            completion(self.users![post.userId])
        }
    }
    
    func loadCollectionFrom<T: Decodable>(urlString: String, completion: @escaping (Result<[T], AnyError>) -> ())
        where T == T.DecodedType {
        let session = URLSession(configuration: URLSessionConfiguration.default)

        session.dataTask(with: URL(string: urlString)!) { data, response, error in
            guard case .none = error else {
                completion(.failure(AnyError(error!)))
                return
            }
            
            if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == self.httpOk {
                
                let collection: [T] = self.parseArray(from: data) ?? []
                completion(.success(collection))
            }
            else {
                completion(.success([]))
            }
        }
    }
    
    func parseArray<T: Decodable>(from data: Data) -> [T]? where T == T.DecodedType {
        let json: Any? = try? JSONSerialization.jsonObject(with: data)
        
        guard let j = json else {
            return nil
        }
        
        return decode(j)
    }
    
    func parseObject<T: Decodable>(from data: Data) -> T? where T == T.DecodedType {
        let json: Any? = try? JSONSerialization.jsonObject(with: data)
        
        guard let j = json else {
            return nil
        }
        
        return decode(j)
    }
    
    func loadPostsFromLocalStorage() -> [Post] {
        guard let data = try? Data(contentsOf: localStorageURL),
            let posts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Post] else {
            return []
        }

        return posts
    }
    
    func writePostsToLocalStorage() {
        guard let posts = posts else {
            return
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: posts)
        
        do {
            try data.write(to: localStorageURL, options: .atomic)
        }
        catch {
            NSLog("Error writing posts to local storage: \(error)")
        }
    }
}
