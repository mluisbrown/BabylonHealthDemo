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

class PostDetailViewController: UIViewController {

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
        
        bodyLabel.text = viewModel.post.body
        authorLabel.reactive.text <~ viewModel.userName
        commentCountLabel.reactive.text <~ viewModel.commentCount

        viewModel.loadDetails()
    }
}
