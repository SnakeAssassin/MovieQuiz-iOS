//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 28.10.2023.
//

import UIKit

// Структура для хранения алерта
struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    
    init(title: String, message: String, buttonText: String){
        self.title = title
        self.message = message
        self.buttonText = buttonText
    }
}
