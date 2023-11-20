//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 20.11.2023.
//

import UIKit

/// MVP
final class MovieQuizPresenter {
    
    // MARK: Variables
    
    let questionAmount: Int = 10                        // Общее количество вопросов для квиза
    private var currentQuestionIndex = 0                // Переменная с индексом текущего вопроса
    
    /// Проверка что вопрос последний
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    // MARK: Functions
    
    /// Сброс счетчика вопросов
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    /// Следующий вопрос
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// Конвертирует QuizQuestion -> QuizStepViewModel
    internal func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
}
