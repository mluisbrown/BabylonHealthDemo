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
    struct UrlString {
        private init() {}
        static let posts = "https://jsonplaceholder.typicode.com/posts"
        static let users = "https://jsonplaceholder.typicode.com/users"
        static let comments = "https://jsonplaceholder.typicode.com/comments?postId="
    }
    
    enum PostError: Error {
        case userNotFound
        case abc
    }
    
    private let httpOk = 200
    
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
                self.users = self.loadUsersFromLocalStorage()
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
    
    func loadCollectionFrom<T: Decodable>(urlString: String, completion: @escaping (Result<[T], AnyError>) -> ())
        where T == T.DecodedType {
        let session = URLSession.shared

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
        }.resume()
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
}

// MARK: functions for reading and writing to local storage
extension PostsViewModel {
    struct LocalStorageURL {
        static let users = documentURL(with: "users.json")
        static let posts = documentURL(with: "posts.json")
        
        private static func documentURL(with filename: String) -> URL {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths.first!
            let path = URL(fileURLWithPath: documentsDirectory, isDirectory: true).appendingPathComponent(filename)
            
            return path
        }
    }
    
    func loadUsersFromLocalStorage() -> [Int : User] {
        guard let data = try? Data(contentsOf: LocalStorageURL.users),
            let users: [User] = parseArray(from: data) else {
                return [:]
        }
        
        return userMap(from: users)
    }
    
    func writeUsersToLocalStorage() throws {
        guard let users = users else {
            return
        }
        
        do {
            let data: Data = try wrap(Array(users.values))
            try data.write(to: LocalStorageURL.users, options: .atomic)
        }
        catch {
            NSLog("Error writing users to local storage: \(error)")
            throw error
        }
    }
    
    func loadPostsFromLocalStorage() -> [Post] {
        guard let data = try? Data(contentsOf: LocalStorageURL.posts),
            let posts: [Post] = parseArray(from: data) else {
                return []
        }
        
        return posts
    }
    
    func writePostsToLocalStorage() throws {
        guard let posts = posts else {
            return
        }
        
        do {
            let data: Data = try wrap(posts)
            try data.write(to: LocalStorageURL.posts, options: .atomic)
        }
        catch {
            NSLog("Error writing posts to local storage: \(error)")
            throw error
        }
    }
}
