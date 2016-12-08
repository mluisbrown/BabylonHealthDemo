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
@testable import BabylonHealthDemo

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

    
    override func spec() {
        describe("JSON parsing") {
            it("parses JSON Posts into Posts") {
                let postsViewModel = PostsViewModel()
                
                let data = self.postsJSON.data(using: .utf8)!
                let posts = postsViewModel.parseJsonPosts(from: data)
                expect(posts).toNot(beNil())
                expect(posts?.count).to(equal(2))
            }
        }
        
    }
    
    
}
