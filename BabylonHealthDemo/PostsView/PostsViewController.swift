//
//  PostsViewController.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import UIKit

class PostsViewController: UITableViewController {
    let postCellIdentifier = "postCell"
    
    var dataModel: DataModel?
    var viewModel: PostsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(persistDataModel),
                                               name: .UIApplicationWillResignActive, object: nil)
        
        dataModel = DataModel()
        viewModel = PostsViewModel(dataModel: dataModel!, cellIdentifier: postCellIdentifier) { cell, post in
            cell.textLabel?.text = post.title
        }
        
        tableView.dataSource = viewModel
        
        viewModel?.loadPosts() {
            self.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let post = viewModel?.post(at: indexPath.row),
            let detailVC = segue.destination as? PostDetailViewController else {
            return
        }
        
        detailVC.prepare(dataModel: dataModel!, post: post)
    }
    
    func persistDataModel() {
        dataModel?.persist()
    }
}
