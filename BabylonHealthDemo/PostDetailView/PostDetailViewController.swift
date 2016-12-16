//
//  PostDetailViewController.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 15/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var viewModel: PostDetailViewModel?
    
    func prepare(dataModel: DataModel, post: Post) {
        viewModel = PostDetailViewModel(dataModel: dataModel, post: post)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.loadDetails() { (userName, postBody, commentCount) in
            self.authorLabel.text = userName
            self.bodyLabel.text = postBody
            self.commentCountLabel.text = commentCount
        }
    }
}
