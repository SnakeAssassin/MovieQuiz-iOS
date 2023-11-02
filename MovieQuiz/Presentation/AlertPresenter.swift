//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 28.10.2023.
//

import UIKit

class AlertPresenter: UIViewController, AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?

    func restartGame(model: AlertModel,
                             viewController: MovieQuizViewController,
                             completion: (() -> Void)?) {
        let alertController = UIAlertController(title: model.title,
                                                message: model.message,
                                                preferredStyle: .alert)

        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            completion?()
            self?.delegate?.didReceiveAlert()
        }

        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    } 
}

