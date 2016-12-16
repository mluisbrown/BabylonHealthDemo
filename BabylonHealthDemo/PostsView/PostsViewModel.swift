//
//  PostsViewModel.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import UIKit

typealias CellConfigurator = (_ cell: UITableViewCell, _ post: Post) -> Void

class PostsViewModel: NSObject {
    let dataModel: DataModel
    let cellIdentifier: String
    let configureCell: CellConfigurator
    var posts = [Post]()
    
    init(dataModel: DataModel, cellIdentifier: String, configureCell: @escaping CellConfigurator) {
        self.dataModel = dataModel
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell        
    }
    
    func loadPosts(completion: @escaping () -> Void) {
        dataModel.loadPosts { posts in
            self.posts = posts
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func post(at index: Int) -> Post? {
        guard index < posts.count else {
            return nil
        }
        
        return posts[index]
    }
}

extension PostsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let post = posts[indexPath.row]
        
        configureCell(cell, post)
        return cell
    }
}
