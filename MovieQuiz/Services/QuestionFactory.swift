//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 27.10.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    /// Свойство с делегатом, с которым будет общаться фабрика
    weak var delegate: QuestionFactoryDelegate?
    /// Массив структур с данными вопросов
    private let questions: [QuizQuestion] = [QuizQuestion(image: "The Godfather",
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
    ]
    
    

    
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
    }
}

