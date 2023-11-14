//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 12.11.2023.
//

import Foundation

/// Отвечает за загрузку данных по URL
struct NetworkClient {
    
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
