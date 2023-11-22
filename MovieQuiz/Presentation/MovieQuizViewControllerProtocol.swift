//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 22.11.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: AlertModel)
    func highlightImageBorder(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

