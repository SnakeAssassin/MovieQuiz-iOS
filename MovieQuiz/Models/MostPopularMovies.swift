//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 13.11.2023.
//

import Foundation


/// Для преобразования JSON в Swift-структуру необходимо подписать на протокол Codable
struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    // Изменение качества изображения
    var resizedImageURL: URL {
        // Создаем строку из адреса
        let urlString = imageURL.absoluteString
        // Обрезаем лишнюю часть и добавляем модификатор желаемого качества
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        // Пытаемся создать новый адрес, если не получается - возвращаем старый
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        return newURL
    }
      
    /// Так как имена полей JSON не совпадают с именами структуры, через enum указываем какое поле структуры соответствует полю в JSON
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
