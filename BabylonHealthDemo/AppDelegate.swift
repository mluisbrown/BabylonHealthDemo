//
//  AppDelegate.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 05/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let network = Network(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
        let dataModel = DataModel(network: network)
        
        let navigationController: UINavigationController? = (self.window?.rootViewController as? UINavigationController)  
        let storyboard = UIStoryboard(name: "Main", bundle: nil)  
        if let postsVC = storyboard.instantiateViewController(withIdentifier: "Posts") as? PostsViewController {
            postsVC.prepare(dataModel: dataModel)
            navigationController?.pushViewController(postsVC, animated: false)            
        }        
        
        return true
    }
}

