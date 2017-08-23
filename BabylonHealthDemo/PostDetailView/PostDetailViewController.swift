//
//  PostDetailViewController.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class PostDetailViewController: UIViewController, ErrorAlertPresentable {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var viewModel: PostDetailViewModel!
    
    func prepare(dataModel: DataModel, post: Post) {
        viewModel = PostDetailViewModel(dataModel: dataModel, post: post)        
    }
    
    override func viewDidLoad() {
        guard let _ = viewModel else {
            fatalError("viewModel not initialized.")
        }
        
        super.viewDidLoad()
        
        bindToModel()
        viewModel.loadDetails()
    }
    
    private func bindToModel() {
        bodyLabel.text = viewModel.post.body
        authorLabel.reactive.text <~ viewModel.userName
        commentCountLabel.reactive.text <~ viewModel.commentCount
        
        viewModel.errorMessage.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] errorText in
                self?.showErrorAlert(withMsg: errorText)
        }
        
        viewModel.networkWarningText.signal
            .observe(on: UIScheduler())
            .observeValues{ [weak self] msg in
                self?.navigationItem.prompt = msg
        }
    }    
}
