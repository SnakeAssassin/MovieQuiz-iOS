//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 28.10.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    /// Заменяем func requestNextQuestion() -> QuizQuestion?
    /// Так как он не отдает вопрос сразу, а использует метод делегата, на:
    func requestNextQuestion()
}
