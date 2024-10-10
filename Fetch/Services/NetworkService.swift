//
//  NetworkService.swift
//  Fetch
//
//  Created by Tomas Gonzalez on 10/6/24.
//
import Foundation

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    private var session: URLSession
    private var decoder: JSONDecoder

    //
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetch<T: Decodable>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensure we received data
            guard let data = data, !data.isEmpty else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Try to decode the data using the injected decoder
            do {
                let decodedData = try self.decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
