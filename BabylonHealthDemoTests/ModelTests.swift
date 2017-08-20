//
//  PostTests.swift
//  BabylonHealthDemoTests
//
//  Created by Michael Brown on 20/08/2017.
//  Copyright © 2017 Michael Brown. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import BabylonHealthDemo

private func decodingError(_ error: Error) -> String {
    switch error {
    case DecodingError.dataCorrupted(let context), 
         DecodingError.keyNotFound(_, let context), 
         DecodingError.typeMismatch(_, let context):
        return context.debugDescription
    default:
        return error.localizedDescription
    }
}

class ModelTests: QuickSpec {
    let postsData = 
    """
    [
        {
            "id": 1,
            "userId": 1,
            "title": "a title",
            "body": "a body"
        },
        {
            "id": 2,
            "userId": 1,
            "title": "another title",
            "body": "another body",
            "comments": [
                {
                    "postId": 2,
                    "id": 1,
                    "name": "comment name",
                    "email": "Eliseo@gardner.biz",
                    "body": "comment body"
                }
            ]
        }
    ]
    """.data(using: .utf8)! 
    
    let usersData =
    """
    [
        {
            "id": 1,
            "name": "a name",
            "username": "a username"
        },
        {
            "id": 2,
            "name": "another name",
            "email": "an e-mail"
        }
    ]
    """.data(using: .utf8)!
    
    override func spec() {
        describe("JSON parsing") {
            it("parses JSON Posts into Posts") {
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: self.postsData)
                    expect(posts).toNot(beNil())
                    expect(posts.count).to(equal(2))
                } catch {
                    fail(decodingError(error))
                }
            }
            
            it("parses JSON Users into Users") {
                do {
                    let users = try JSONDecoder().decode([User].self, from: self.usersData)
                    expect(users).toNot(beNil())
                    expect(users.count).to(equal(2))
                } catch {
                    fail(decodingError(error))
                }
            }
        }
    }
    
}
