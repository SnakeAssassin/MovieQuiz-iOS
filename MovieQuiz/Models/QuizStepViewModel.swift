//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 27.10.2023.
//

import Foundation
/// Т.к. QuizStepViewModel имеет свойство типа UIImage – код этого класса содержится в библиотеке UIKit, поэтому необходимо его импортировать.
import UIKit

/// View-модель для состояния "Вопрос показан"
struct QuizStepViewModel {
    // Изображение с афишей фильма с типом UIImage
    let image: UIImage
    // Вопрос о рейтинге фильма
    let question: String
    // Порядковый номер вопроса (1/10)
    let questionNumber: String
}
