//
//  PostDetailViewModel.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import ReactiveSwift

struct PostDetailViewModel {
    let dataModel: DataModel
    let post: Post
    
    let userName = MutableProperty("")
    let commentCount = MutableProperty("")
    
    init(dataModel: DataModel, post: Post) {
        self.dataModel = dataModel
        self.post = post
        
        createBindings()
    }
    
    private func createBindings() {
        dataModel.user.signal
            .skipNil()
            .observeValues { user in
                self.userName.value = user.name
        }        
        
        dataModel.comments.signal
            .observeValues { comments in
                self.commentCount.value = String(comments.count)
        }
    }
    
    func loadDetails() {
        dataModel.loadUser(with: post.userId)         
        dataModel.loadComments(for: post.id) 
    }    
}
