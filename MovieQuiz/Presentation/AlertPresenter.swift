//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 28.10.2023.
//

import UIKit

final class AlertPresenter {

    let alertModel: AlertModel
    weak var viewController: UIViewController?

    init(alertModel: AlertModel, viewController: UIViewController) {
        self.alertModel = alertModel
        self.viewController = viewController
    }

    func showAlert() {
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        
        // Передаем идентификатор алерту для тестов
        if let alertView = alert.view {
            alertView.accessibilityIdentifier = "AlertIdentifier"
        }
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { /*[weak self]*/ _ in
            self.alertModel.completion()
        }
        
        guard let viewController = viewController else { return }
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
