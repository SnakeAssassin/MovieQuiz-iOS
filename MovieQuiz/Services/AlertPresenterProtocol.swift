//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 29.10.2023.
//

import Foundation

/// Протокол AlertPresenter'а
protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    func restartGame(model: AlertModel,
                             viewController: MovieQuizViewController,
                             completion: (() -> Void)?)
}

