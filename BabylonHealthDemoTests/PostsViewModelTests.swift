//
//  PostsViewModelTests.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 08/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Kakapo
import Argo
import Runes
@testable import BabylonHealthDemo

extension Post: Serializable {
    
}

extension User: Serializable {
    
}


class PostsViewModelTests: QuickSpec {
    
    let postsJSON = "[" +
        "{" +
            "\"userId\": 1," +
            "\"id\": 1," +
            "\"title\": \"sunt aut facere repellat provident occaecati excepturi optio reprehenderit\"," +
            "\"body\": \"quia et suscipit\\nsuscipit recusandae consequuntur expedita et cum\\nreprehenderit molestiae ut ut quas totam\\nnostrum rerum est autem sunt rem eveniet architecto\"" +
        "}," +
        "{" +
            "\"userId\": 1," +
            "\"id\": 2," +
            "\"title\": \"qui est esse\"," +
            "\"body\": \"est rerum tempore vitae\\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\\nqui aperiam non debitis possimus qui neque nisi nulla\"" +
        "}" +
    "]"

    let usersJSON =
        "[" +
            "  {" +
            "    \"id\": 1," +
            "    \"name\": \"Leanne Graham\"," +
            "    \"username\": \"Bret\"," +
            "    \"email\": \"Sincere@april.biz\"," +
            "    \"address\": {" +
            "      \"street\": \"Kulas Light\"," +
            "      \"suite\": \"Apt. 556\"," +
            "      \"city\": \"Gwenborough\"," +
            "      \"zipcode\": \"92998-3874\"," +
            "      \"geo\": {" +
            "        \"lat\": \"-37.3159\"," +
            "        \"lng\": \"81.1496\"" +
            "      }" +
            "    }," +
            "    \"phone\": \"1-770-736-8031 x56442\"," +
            "    \"website\": \"hildegard.org\"," +
            "    \"company\": {" +
            "      \"name\": \"Romaguera-Crona\"," +
            "      \"catchPhrase\": \"Multi-layered client-server neural-net\"," +
            "      \"bs\": \"harness real-time e-markets\"" +
            "    }" +
            "  }," +
            "  {" +
            "    \"id\": 2," +
            "    \"name\": \"Ervin Howell\"," +
            "    \"username\": \"Antonette\"," +
            "    \"email\": \"Shanna@melissa.tv\"," +
            "    \"address\": {" +
            "      \"street\": \"Victor Plains\"," +
            "      \"suite\": \"Suite 879\"," +
            "      \"city\": \"Wisokyburgh\"," +
            "      \"zipcode\": \"90566-7771\"," +
            "      \"geo\": {" +
            "        \"lat\": \"-43.9509\"," +
            "        \"lng\": \"-34.4618\"" +
            "      }" +
            "    }," +
            "    \"phone\": \"010-692-6593 x09125\"," +
            "    \"website\": \"anastasia.net\"," +
            "    \"company\": {" +
            "      \"name\": \"Deckow-Crist\"," +
            "      \"catchPhrase\": \"Proactive didactic contingency\"," +
            "      \"bs\": \"synergize scalable supply-chains\"" +
            "    }" +
            "  }" +
    "]"

    let posts = [Post(id: 1, userId: 1, title: "a title", body: "a body", comments: []),
                 Post(id: 2, userId: 1, title: "another title", body: "another body", comments: [])]
    
    let users = [User(id: 1, name: "a name"), User(id: 2, name: "another name")]
    let userMap = [1 : User(id: 1, name: "a name"), 2 : User(id: 2, name: "another name")]
    
    
    override func spec() {
        describe("JSON parsing") {
            it("parses JSON Posts into Posts") {
                let data = self.postsJSON.data(using: .utf8)!
                let posts: [Post]? = try? parseArray(from: data).dematerialize()
                expect(posts).toNot(beNil())
                expect(posts?.count).to(equal(2))
            }
            
            it("parses JSON Users into Users") {
                let data = self.usersJSON.data(using: .utf8)!
                let users: [User]? = try? parseArray(from: data).dematerialize()
                expect(users).toNot(beNil())
                expect(users?.count).to(equal(2))
            }
        }
        
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
                
                let postsFromStorage: [Post]
                try? write(collection: self.posts, to: LocalResource.posts)
                postsFromStorage = loadCollection(from: LocalResource.posts)
                
                expect(postsFromStorage.count).to(equal(2))
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
                
                let usersFromStorage: [User]
                try? write(collection: self.users, to: LocalResource.users)
                usersFromStorage = loadCollection(from: LocalResource.users)
                
                expect(usersFromStorage.count).to(equal(2))
            }
            
        }
        
        describe("network requests") {
            let router = Router.register("https://jsonplaceholder.typicode.com")
            router.get("/posts") { request in
                return self.posts
            }
            router.get("/users") { request in
                return self.users
            }
            
            it("loads posts from the network") {
                try? FileManager.default.removeItem(at: LocalResource.posts)

                let postsViewModel = PostsViewModel()
                var loadedPosts = [Post]()
                postsViewModel.loadPosts() { somePosts in
                    loadedPosts = somePosts
                }
                
                expect(loadedPosts.count).toEventually(equal(2))
            }

            it("loads users from the network") {
                try? FileManager.default.removeItem(at: LocalResource.users)
                
                let postsViewModel = PostsViewModel()
                var user: User?
                postsViewModel.loadUser(for: self.posts.first!) { aUser in
                    user = aUser
                }
                
                expect(user).toEventuallyNot(beNil())
                expect(user!.id).toEventually(equal(1))
            }
        }
    }
}
