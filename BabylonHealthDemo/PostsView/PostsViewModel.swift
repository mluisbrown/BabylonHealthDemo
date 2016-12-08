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
    private let postsUrl = "http://jsonplaceholder.typicode.com/posts"
    private let httpOk = 200
    
    private let localStorageURL: URL = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        let path = URL(fileURLWithPath: documentsDirectory, isDirectory: true).appendingPathComponent("posts.plist")

        return path
    }()
    
    var posts: [Post]?
    
    func loadPosts(completion: @escaping (_ posts: [Post]) -> ()) {
        guard case .none = posts else {
            completion(self.posts!)
            return
        }
        
        loadPostsFromNetwork { result in
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
    
    func loadPostsFromNetwork(completion: @escaping (Result<[Post], AnyError>) -> ()) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: URL(string: postsUrl)!) { data, response, error in
            guard case .none = error else {
                completion(.failure(AnyError(error!)))
                return
            }
            
            if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == self.httpOk {
                
                let posts: [Post] = self.parseJsonPosts(from: data) ?? []
                completion(.success(posts))
            }
            else {
                completion(.success([]))
            }
        }
    }
    
    func parseJsonPosts(from data: Data) -> [Post]? {
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
