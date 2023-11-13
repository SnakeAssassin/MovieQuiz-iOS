//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 28.10.2023.
//

import UIKit

// Структура для хранения алерта
public struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
