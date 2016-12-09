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

    let userJSON = "{" +
        "  \"id\": 4," +
        "  \"name\": \"Patricia Lebsack\"," +
        "  \"username\": \"Karianne\"," +
        "  \"email\": \"Julianne.OConner@kory.org\"," +
        "  \"address\": {" +
        "    \"street\": \"Hoeger Mall\"," +
        "    \"suite\": \"Apt. 692\"," +
        "    \"city\": \"South Elvis\"," +
        "    \"zipcode\": \"53919-4257\"," +
        "    \"geo\": {" +
        "      \"lat\": \"29.4572\"," +
        "      \"lng\": \"-164.2990\"" +
        "    }" +
        "  }," +
        "  \"phone\": \"493-170-9623 x156\"," +
        "  \"website\": \"kale.biz\"," +
        "  \"company\": {" +
        "    \"name\": \"Robel-Corkery\"," +
        "    \"catchPhrase\": \"Multi-tiered zero tolerance productivity\"," +
        "    \"bs\": \"transition cutting-edge web services\"" +
        "  }" +
        "}"
    
    override func spec() {
        describe("JSON parsing") {
            it("parses JSON Posts into Posts") {
                let postsViewModel = PostsViewModel()
                
                let data = self.postsJSON.data(using: .utf8)!
                let posts: [Post]? = postsViewModel.parseArray(from: data)
                expect(posts).toNot(beNil())
                expect(posts?.count).to(equal(2))
            }
            
            it("parses a JSON User") {
                let postsViewModel = PostsViewModel()
                
                let data = self.userJSON.data(using: .utf8)!
                let user: User? = postsViewModel.parseObject(from: data)
                expect(user).toNot(beNil())
            }
        }
        
    }
    
    
}
