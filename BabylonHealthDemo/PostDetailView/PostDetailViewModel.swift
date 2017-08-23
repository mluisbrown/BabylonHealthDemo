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
    let errorMessage = MutableProperty("")
    let networkWarningText = MutableProperty<String?>(nil)
    
    init(dataModel: DataModel, post: Post) {
        self.dataModel = dataModel
        self.post = post

        createBindings()
    }
    
    func createBindings() {
        networkWarningText <~ dataModel.networkAvailable
            .signal
            .skipRepeats()
            .map {
                return $0 ? nil : "Network unavailable"
        }
    }
    
    func loadDetails() {
        dataModel.loadUsers().startWithResult { 
            switch $0 {
            case .success(let users):
                if let user = users[self.post.userId] {
                    self.userName.value = user.name
                }
            case .failure(let error):
                self.errorMessage.value = error.localizedDescription
            }
        }         
        
        dataModel.loadComments(for: post.id).startWithResult {
            switch $0 {
            case .success(let comments):
                self.commentCount.value = String(comments.count)
            case .failure(let error):
                self.errorMessage.value = error.localizedDescription
            }
        } 
    }    
}
