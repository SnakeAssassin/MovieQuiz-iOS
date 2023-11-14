//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 13.11.2023.
//

import Foundation

/// Сервис для загрузки фильмов через NetworkClient и преобразование JSON в модель данных MostPopularMovies
protocol MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

/// Загрузчик, реализующий этот протокол
struct MoviesLoader: MoviesLoadingProtocol {
    /// Создаем экземпляр NetworkClient, через который будем создавать запросы к API
    private let networkClient = NetworkClient()
    
    /// URL
    private var mostPopularMoviesUrl: URL {
        // Если не получится преобразовать строку в URL, то приложение упадет с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    /// Функция загрузки фильмов через асинхронный запрос и передача результата обратно через переданное замыкание handler
    /// Принимает замыкание handler в качестве параметра
    /// Тип замыкания (Result<MostPopularMovies, Error>) -> Void
    /// @escaping – замыкание может быть сохранено для последующего вызова
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        /// Вызов метода fetch (асинхронный запрос данных из сети)
        /// Используется замыкание, которое принимает result
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            /// Конструкция switch, которая проверяет значение result
            switch result {
            /// Если результат запроса успешен, то извлекается ассоциированное значение data из результ
            case .success(let data):
                /// Попытка декодировать данные data в структуру MostPopularMovies
                /// Если декодирование успешно, вызывается handler с результатом .success и распакованным объектом mostPopularMovies
                /// В случае ошибки вызывается handler с результатом .failure и передается сама ошибка
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            /// Из результата запроса failure извлекается ассоциированное значение error из result и вызывается handler с результатом .failure и передается ошибка
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
}
