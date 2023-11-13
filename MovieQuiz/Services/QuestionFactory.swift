//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 27.10.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    

    
    /// Экземпляр загрузчика данных (добавлен как зависимость QuestionFactory)
    private let moviesLoader: MoviesLoadingProtocol
         
    /// Свойство с делегатом, с которым будет общаться фабрика
    private weak var delegate: QuestionFactoryDelegate?
    
    ///
    var errorMessage: String
    
    /// Инициализатор, чтобы передавать загрузчик и делегат в момент создания QuestionFactory
    init(moviesLoader: MoviesLoadingProtocol, errorMessage: String ,delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.errorMessage = errorMessage
        self.delegate = delegate
    }
    
    
    /// Инициализирует загрузку данных
    func loadData() {
        /// Передаем result в handler асинхронно через замыкание
        moviesLoader.loadMovies { [weak self] result in
            
            /// Сетевые запросы работают в другом потоке, поэтому после обработки ответа от загрузчика необходимо перейти в главный поток
            DispatchQueue.main.async {
            
            guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.errorMessage = mostPopularMovies.errorMessage
                    self.movies = mostPopularMovies.items   // Сохраняем фильм в переменную movies
                    self.delegate?.didLoadDataFromServer()  // Сообщаем через delegate что данные загружены MovieQuizController'у
                case.failure(let error):
                    self.delegate?.didFailToLoadData(with: error)   // Сообщаем через delegate об ошибке MovieQuizViewController'у
                }
            }
        }
    }
    
    
    /// Переменная для хранения загруженных из сети фильмов
    private var movies: [MostPopularMovie] = []
    
    /// Массив структур с данными вопросов
    /*private let questions: [QuizQuestion] = [QuizQuestion(image: "The Godfather",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "The Dark Knight",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "Kill Bill",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "The Avengers",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "Deadpool",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "The Green Knight",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "Old",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false),
                                             QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false),
                                             QuizQuestion(image: "Tesla",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false),
                                             QuizQuestion(image: "Vivarium",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false)
    ]*/
    
    
/*
    
    /// 1.      Метод ничего не принимает и возращает вопрос сразу, а передает его делегату QuestionFactoryDelegate в функцию didReceiveNextQuestion(question: )
    ///     Опциональная, так как, если массив questions пуст, то приложение бы упало, иначе вернется nil, если получить следующий вопрос невозможно.
    /// 2.      Выбираем случайный индекс вопроса из массива от 0 до последнего индекса.
    ///     оператор меньше т.к. последний элемент будет 10, а счет массива 0 до 9, поэтому оператор меньше возьмет значение за n-1
    ///     Функция randomElement случайно выберет число и вернет опционал, который безопасно распаковывается через guard let.
    /// 3.      Вызов расширения (Array+Extensions) через subscript [safe: index].
    ///     Расширение проверяет не выходит ли индекс за рамки массива (возвращает значение в этом индексе) и вместо падения приложения вернет nil.
    func requestNextQuestion() {   // 1
        guard let index = (0..<questions.count).randomElement() else {    // 2
            /// иначе передает nil делегату QuestionFactoryDelegate в функцию didReceiveNextQuestion(question: )
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        /// Если questions не пустой, то вызывается метод делегата и передается модель вопроса в него
        let question = questions[safe: index]   // 3
        delegate?.didReceiveNextQuestion(question: question)
    } */
    
    func requestNextQuestion() {
        
        /// Работа с изображениями и сетью должна быть в отдельном потоке, чтобы не блокировать основной поток, поэтому запускаем асинхронно в другом потоке через global()
        DispatchQueue.global().async { [weak self] in
            /// Выбираем рандомный элемент массива чтобы показать его
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            /// Создаем данные из URL , т.к. у типа Data есть возможность быть созданным из URL
            var imageData = Data()  // создаем пустой объект типа Data
           
           do {
                
               imageData = try Data(contentsOf: movie.resizedImageURL)    // Пробуем загрузить данные по URL
            } catch {
                
                self.delegate?.didFailToLoadData(with: error)
                print("Failed to load image")                              // Если неуспешно, то выводим ошибку
            }
            
            /// Создаем вопрос, определяем корректность и создаем модель вопроса
            let randomAnswerRating = Int.random(in: 6...8)
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем \(randomAnswerRating)?"
            let correctAnswer = rating > Float(randomAnswerRating)
            /// Заполняем модель QuizQuestion
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            /// После окончания загрузку и обработки данных, возвращаем вопрос через delegate в основной поток через main
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    
    
    
}

