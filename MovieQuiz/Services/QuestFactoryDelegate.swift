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
    
    /// Сообщение об успешной загрузке
    func didLoadDataFromServer()
    /// Сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error)
    /// Сообщение об ошибке от API
    func didLoadErrorFromAPI(with error: String)
}
