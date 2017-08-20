//
//  Network.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 14/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

typealias Response = SignalProducer<(Data, URLResponse), DataError>

class Network {
    let session: URLSession
    let baseURL: URL
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), baseURL: URL) {
        self.session = session
        self.baseURL = baseURL
    }
 
    func makeRequest(_ resource: Resource) -> Response {
        let request = resource.toRequest(self.baseURL)
        
        return self.session.reactive
            .data(with: request)
            .mapError { DataError.network($0.localizedDescription) }        
            .start(on: QueueScheduler(name: "Network"))            
    }
    
    deinit {
        self.session.invalidateAndCancel()
    }
}

