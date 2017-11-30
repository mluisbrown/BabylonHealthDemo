//
//  PostsViewModel.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

typealias CellConfigurator = (_ cell: UITableViewCell, _ post: Post) -> Void

struct PostsViewModel {
    let dataModel: DataModel
    let posts = MutableProperty([Post]())
    let errorMessage = MutableProperty("")
    let networkWarningText = MutableProperty<String?>(nil)
    let tableViewDataSource: UITableViewDataSource
    
    init(dataModel: DataModel, cellIdentifier: String, configureCell: @escaping CellConfigurator) {
        self.dataModel = dataModel
        self.tableViewDataSource = PostsViewModelDataSource(cellIdentifier: cellIdentifier, configureCell: configureCell, posts: Property(posts))
        
        createBindings()
    }
    
    func createBindings() {
        networkWarningText <~ dataModel.networkAvailable
            .producer
            .skipRepeats()
            .map {
                return $0 ? nil : "Network unavailable"
            }
    }
    
    func loadPosts() {
        dataModel.loadPosts().startWithResult { 
            switch $0 {
            case .success(let posts):
                self.posts.value = posts
            case .failure(let error):
                self.errorMessage.value = error.localizedDescription
            }
        }
    }
    
    func post(at index: Int) -> Post? {
        guard index < posts.value.count else {
            return nil
        }
        
        return posts.value[index]
    }
}

class PostsViewModelDataSource: NSObject {
    let configureCell: CellConfigurator
    let cellIdentifier: String
    let posts: Property<[Post]>
    
    init(cellIdentifier: String, configureCell: @escaping CellConfigurator, posts: Property<[Post]>) {
        self.configureCell = configureCell
        self.cellIdentifier = cellIdentifier
        self.posts = posts
    }
}

extension PostsViewModelDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let post = posts.value[indexPath.row]
        
        configureCell(cell, post)
        return cell
    }
}
