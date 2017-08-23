//
//  ErrorAlertPresentable.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 23/08/2017.
//  Copyright © 2017 Michael Brown. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorAlertPresentable: class {
}

extension ErrorAlertPresentable where Self: UIViewController {
    func showErrorAlert(withMsg msg: String) {
        let alertVC = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        present(alertVC, animated: true, completion: nil)
    }        
}
