//
//  DataModelTests.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 08/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Kakapo
import Result
import ReactiveSwift
@testable import BabylonHealthDemo

// Serializable protocol used by Kakapo for network mocking
extension Post: Serializable {}
extension User: Serializable {}


class DataModelTests: QuickSpec {
    
    let posts = [Post(id: 1, userId: 1, title: "a title", body: "a body", comments: []),
                 Post(id: 2, userId: 1, title: "another title", body: "another body", comments: [])]
    
    let users = [User(id: 1, name: "a name"),
                 User(id: 2, name: "another name")]
    
    override func spec() {
        
        describe("local storage") {
            it("stores posts to local storage") {
                try? FileManager.default.removeItem(at: LocalResource.posts)
                
                var threw = false
                do {
                    try write(collection: self.posts, to: LocalResource.posts)
                } catch {
                    threw = true
                }
                
                expect(threw).to(beFalse())
            }

            it("reads posts from local storage") {
                try? FileManager.default.removeItem(at: LocalResource.posts)
                
                var postsFromStorage: [Post] = []
                try? write(collection: self.posts, to: LocalResource.posts)
                read(from: LocalResource.posts).startWithResult {
                    switch $0 {
                    case .success(let data):
                        postsFromStorage = try! JSONDecoder().decode([Post].self, from: data)
                    case .failure(let error):
                        fail("read posts failed: \(error.localizedDescription)")
                    }
                }
                
                expect(postsFromStorage.count).toEventually(equal(2))
            }
            
            it("writes users to local storage") {
                try? FileManager.default.removeItem(at: LocalResource.users)
                
                var threw = false
                do {
                    try write(collection: self.users, to: LocalResource.users)
                } catch {
                    threw = true
                }
                
                expect(threw).to(beFalse())
            }

            it("reads users from local storage") {
                try? FileManager.default.removeItem(at: LocalResource.users)
                
                var usersFromStorage: [User] = []
                try? write(collection: self.users, to: LocalResource.users)
                read(from: LocalResource.users).startWithResult {
                    switch $0 {
                    case .success(let data):
                        usersFromStorage = try! JSONDecoder().decode([User].self, from: data)
                    case .failure(let error):
                        fail("read users failed: \(error.localizedDescription)")
                    }
                }
                
                expect(usersFromStorage.count).toEventually(equal(2))
            }
            
        }
        
        describe("network requests") {
            let baseURL = "https://jsonplaceholder.typicode.com"
            let router = Router.register(baseURL)
            router.get("/posts") { request in
                return self.posts
            }
            router.get("/users") { request in
                return self.users
            }
            
            it("loads posts from the network") {
                try? FileManager.default.removeItem(at: LocalResource.posts)

                let dataModel = DataModel(network: Network(session: URLSession.shared, baseURL: URL(string: baseURL)!))
                let loadedPosts = MutableProperty([Post]())
                dataModel.loadPosts().startWithResult {
                    switch $0 {
                    case .success(let posts):
                        loadedPosts.value = posts
                    case .failure(let error):
                        fail("loadPosts failed: \(error.localizedDescription)")
                    }                    
                }
                
                expect(loadedPosts.value.count).toEventually(equal(2))
            }

            it("loads users from the network") {
                try? FileManager.default.removeItem(at: LocalResource.users)
                
                let dataModel = DataModel(network: Network(session: URLSession.shared, baseURL: URL(string: baseURL)!))
                let loadedUser = MutableProperty<User?>(nil)

                dataModel.loadUsers().startWithResult {
                    switch $0 {
                    case .success(let users):
                        loadedUser.value = users[self.posts.first!.userId]
                    case .failure(let error):
                        fail("loadUsers failed: \(error.localizedDescription)")
                    }
                }
                
                expect(loadedUser).toEventuallyNot(beNil())
                expect(loadedUser.value?.id).toEventually(equal(1))
            }
        }
    }
}
