//
//  Network.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 14/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Result
import Argo

enum HTTPStatusCode: Int {
    case ok = 200
}

enum NetworkError: Error {
    case noData
    case badRequest(String)
    case jsonParsing(String)
}

struct NetworkResource {
    private init() {}
    static let posts = "https://jsonplaceholder.typicode.com/posts"
    static let users = "https://jsonplaceholder.typicode.com/users"
    static let comments = "https://jsonplaceholder.typicode.com/comments?postId="
}


func loadCollection<T: Decodable>(from urlString: String, completion: @escaping (Result<[T], NetworkError>) -> ())
    where T == T.DecodedType {
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
            guard case .none = error else {
                completion(.failure(.badRequest(error!.localizedDescription)))
                return
            }
            
            if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == HTTPStatusCode.ok.rawValue {
                
                do {
                    let decoded: Argo.Decoded<[T]> = try parseArray(from: data)
                    switch decoded {
                    case .success(let collection):
                        completion(.success(collection))
                    case .failure(let error):
                        completion(.failure(.jsonParsing(error.localizedDescription)))
                    }
                } catch {
                    completion(.failure(.jsonParsing(error.localizedDescription)))
                }
            }
            else {
                completion(.failure(.noData))
            }
        }.resume()
}

func parseArray<T: Decodable>(from data: Data) throws -> Argo.Decoded<[T]> where T == T.DecodedType {
    do {
        let json = try JSONSerialization.jsonObject(with: data)
        return decode(json)
    } catch {
        throw error
    }
}    
