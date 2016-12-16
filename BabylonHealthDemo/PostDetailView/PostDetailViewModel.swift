//
//  PostDetailViewModel.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation

typealias PostDetailBinding = (_ userName: String, _ postBody: String, _ commentCount: String) -> Void

class PostDetailViewModel {
    let dataModel: DataModel
    let post: Post
    
    var user: User?
    var comments: [Comment]?
    
    init(dataModel: DataModel, post: Post) {
        self.dataModel = dataModel
        self.post = post
    }
    
    func loadDetails(completion: @escaping PostDetailBinding) {
        dataModel.loadUser(with: post.userId) { user in
            self.user = user
            
            DispatchQueue.main.async {
                completion(self.user?.name ?? "", self.post.body, "\(self.comments?.count ?? 0)")
            }
        }
        
        dataModel.loadComments(for: post.id) { comments in
            self.comments = comments

            DispatchQueue.main.async {
                completion(self.user?.name ?? "", self.post.body, "\(self.comments?.count ?? 0)")
            }
        }
    }    
}
