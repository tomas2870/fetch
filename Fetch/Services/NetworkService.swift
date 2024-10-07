//
//  NetworkService.swift
//  Fetch
//
//  Created by Tomas Gonzalez on 10/6/24.
//
import Foundation

class NetworkService {
    private var session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    // Generic function to fetch data and decode it into any Decodable model
    func fetch<T: Decodable>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = session.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                // If error is nil, provide a fallback error message
                let errorMessage = error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(errorMessage))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch let decodingError{
                completion(.failure(decodingError))
            }
        }
        task.resume()
    }
}

