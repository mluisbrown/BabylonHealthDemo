//
//  PostsViewController.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import UIKit
import ReactiveSwift

class PostsViewController: UITableViewController {
    let postCellIdentifier = "postCell"
    
    var dataModel: DataModel!
    var viewModel: PostsViewModel!
    
    func prepare(dataModel: DataModel) {
        self.dataModel = dataModel
        viewModel = PostsViewModel(dataModel: dataModel, cellIdentifier: postCellIdentifier) { cell, post in
            cell.textLabel?.text = post.title
        }
    }
    
    override func viewDidLoad() {
        guard let _ = dataModel, let _ = viewModel else {
            fatalError("dataModel or viewModel not initialized.")
        }
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(persistDataModel),
                                               name: .UIApplicationWillResignActive, object: nil)
        
        tableView.dataSource = viewModel
        viewModel.posts.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.loadPosts()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let post = viewModel?.post(at: indexPath.row),
            let detailVC = segue.destination as? PostDetailViewController else {
            return
        }
        
        detailVC.prepare(dataModel: dataModel, post: post)
    }
    
    func persistDataModel() {
        dataModel.persist()
    }
}
