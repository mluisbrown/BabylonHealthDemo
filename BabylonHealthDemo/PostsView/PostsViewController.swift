//
//  PostsViewController.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import UIKit
import ReactiveSwift

class PostsViewController: UITableViewController, ErrorAlertPresentable {
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
        
        tableView.dataSource = viewModel.tableViewDataSource
        
        bindToModel()
        viewModel.loadPosts()
    }
    
    private func bindToModel() {
        viewModel.posts.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.tableView.reloadData()
        }
        
        viewModel.errorMessage.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] errorText in
                self?.showErrorAlert(withMsg: errorText)
        }
        
        navigationItem.reactive.prompt <~ viewModel.networkWarningText.producer
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
