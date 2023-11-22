//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 27.10.2023.
//

import Foundation

/// Структура для хранения информации о вопросе, изображении и правильном ответе.
struct QuizQuestion {
    // Строка с названием фильма совпадает с названием картинки афиши фильма в Assets
    let image: Data
    // Строка с вопросом о рейтинге фильма
    let text: String
    // Булевое значение (true/false), правильный ответ на вопрос
    let correctAnswer: Bool
}
