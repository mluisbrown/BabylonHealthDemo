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


struct NetworkResource {
    private init() {}
    static let posts = "https://jsonplaceholder.typicode.com/posts"
    static let users = "https://jsonplaceholder.typicode.com/users"
    static let comments = "https://jsonplaceholder.typicode.com/comments?postId=%d"
}

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


//func loadCollection<T: Decodable>(from urlString: String, completion: @escaping (Result<[T], NetworkError>) -> ()) {
//        
//        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
//            guard case .none = error else {
//                completion(.failure(.badRequest(error!.localizedDescription)))
//                return
//            }
//            
//            if let data = data,
//                let response = response as? HTTPURLResponse,
//                response.statusCode == HTTPStatusCode.ok.rawValue {
//
//                let decoded: Result<[T], NetworkError> = parseArray(from: data)
//                completion(decoded)
//            }
//            else {
//                completion(.failure(.noData))
//            }
//        }.resume()
//}
//
//func parseArray<T: Decodable>(from data: Data) -> Result<[T], NetworkError> {
//    do {
//        let json:[T] = try JSONDecoder().decode([T].self, from: data)
//        return .success(json)
//    } catch {
//        return .failure(.jsonParsing(error.localizedDescription))
//    }
//}    

