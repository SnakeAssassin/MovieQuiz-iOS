//
//  QuestFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 28.10.2023.
//

import Foundation
/// Отдельный протокол для использования в фабрике вопросов, в качестве делегата
protocol QuestionFactoryDelegate: AnyObject {
    /// Метод, который будет у делегата фабрики вопросов.
    /// Его вызывает фабрика, чтобы отдать готовый список вопросов.
    func didReceiveNextQuestion(question: QuizQuestion?) 
}
