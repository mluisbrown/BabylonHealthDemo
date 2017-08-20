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

//            it("reads posts from local storage") {
//                try? FileManager.default.removeItem(at: LocalResource.posts)
//                
//                let postsFromStorage: [Post]
//                try? write(collection: self.posts, to: LocalResource.posts)
//                postsFromStorage = loadCollection(from: LocalResource.posts)
//                
//                expect(postsFromStorage.count).to(equal(2))
//            }
            
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

//            it("reads users from local storage") {
//                try? FileManager.default.removeItem(at: LocalResource.users)
//                
//                let usersFromStorage: [User]
//                try? write(collection: self.users, to: LocalResource.users)
//                usersFromStorage = loadCollection(from: LocalResource.users)
//                
//                expect(usersFromStorage.count).to(equal(2))
//            }
            
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
                loadedPosts <~ dataModel.posts
                dataModel.loadPosts() 
                
                expect(loadedPosts.value.count).toEventually(equal(2))
            }

            it("loads users from the network") {
                try? FileManager.default.removeItem(at: LocalResource.users)
                
                let dataModel = DataModel(network: Network(session: URLSession.shared, baseURL: URL(string: baseURL)!))
                let loadedUser = MutableProperty<User?>(nil)
                loadedUser <~ dataModel.user
                dataModel.loadUser(with: self.posts.first!.userId)
                
                expect(loadedUser).toEventuallyNot(beNil())
                expect(loadedUser.value?.id).toEventually(equal(1))
            }
        }
    }
}
