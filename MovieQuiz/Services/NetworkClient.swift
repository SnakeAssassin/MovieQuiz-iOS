//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 12.11.2023.
//

import Foundation

/// Протокол для реализации тестов
protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

/// Отвечает за загрузку данных по URL
struct NetworkClient: NetworkRouting {
    
    /// 1. Сетевая ошибка
    private enum NetworkError: Error {
        case codeError
    }
    
    /// 2. Функция запроса
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        /// 3. Создаем запрос
        let request = URLRequest(url: url)  // тут URL
        
        // В ответе data, response, error опциональные
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            /// 4. Распаковываем ошибку
            if let error = error {  // Проверяем, пришла ли ошибка
                handler(.failure(error))
                return  // Если ошибка - завершаем код
            }
            
            /// 5. Обрабатываем код ответа
            if let response = response as? HTTPURLResponse, // Проверяем, что нам пришёл успешный код ответа
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return  // Если код - завершаем код
            }
            
            /// 6. Обрабатываем успешный ответ
            guard let data = data else { return }
            handler(.success(data)) // Возвращаем данные в формате Data
        }
        
        task.resume()
    }
}


// Стаб для теста
struct StubNetworkClient: NetworkRouting {
    
    enum TestError: Error { // тестовая ошибка
    case test
    }
    
    let emulateError: Bool // этот параметр нужен, чтобы заглушка эмулировала либо ошибку сети, либо успешный ответ
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
    
    private var expectedResponse: Data {
        """
        {
           "errorMessage" : "",
           "items" : [
              {
                 "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                 "fullTitle" : "Prey (2022)",
                 "id" : "tt11866324",
                 "imDbRating" : "7.2",
                 "imDbRatingCount" : "93332",
                 "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "1",
                 "rankUpDown" : "+23",
                 "title" : "Prey",
                 "year" : "2022"
              },
              {
                 "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                 "fullTitle" : "The Gray Man (2022)",
                 "id" : "tt1649418",
                 "imDbRating" : "6.5",
                 "imDbRatingCount" : "132890",
                 "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "2",
                 "rankUpDown" : "-1",
                 "title" : "The Gray Man",
                 "year" : "2022"
              }
            ]
          }
        """.data(using: .utf8) ?? Data()
    }
}
