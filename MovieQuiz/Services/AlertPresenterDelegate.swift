//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 29.10.2023.
//

import UIKit

/// Протокол делегата AlertPresenter'а
protocol AlertPresenterDelegate: AnyObject {
    func didReceiveAlert()
}
