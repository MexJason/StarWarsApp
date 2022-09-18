//
//  NetworkManager.swift
//  StarWarsApp
//
//  Created by YouTube on 9/16/22.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    let baseURL = "https://swapi.dev/api/people/?format=json"
    
    private init() { }
    
    func standardNetworkCall(completion: @escaping ([Person]?) -> Void) {
        guard let apiURL = URL(string: baseURL) else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: apiURL)) { data, httpResponse, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }
            
            guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completion(response.results)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func networkCallWithResultType(completion: @escaping (Result<[Person], PersonError>) -> Void) {
        guard let apiURL = URL(string: baseURL) else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: apiURL)) { data, httpResponse, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.generalError))
            }
            
            guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.responseError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.generalError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(.decodingError))
            }
            
        }
        task.resume()
    }
    
    func networkWithAsync() async throws -> [Person] {
        guard let apiURL = URL(string: baseURL) else { return [] }
        
        let (data, httpResponse)  = try await URLSession.shared.data(from: apiURL)
        
        guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return []
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(Response.self, from: data)
        return response.results
    }
    
}

enum PersonError: Error {
    case responseError
    case generalError
    case decodingError
}
