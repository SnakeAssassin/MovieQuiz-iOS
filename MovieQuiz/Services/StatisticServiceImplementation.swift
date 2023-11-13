//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 05.11.2023.
//

import Foundation

/// Структура подписана на протокол Codable для сохранения в UserDefaults
struct GameRecord: Codable {
    let correct: Int                                            // кол-во правильных ответов
    let total: Int                                              // общее кол-во вопросов
    let date: String                                            // дата завершения раунда
}

protocol StatisticServiceProtocol {
    func store(correct count: Int, total amount: Int)           // Метод для сохранения текущего результата игры
    var averageAccuracy: Double { get }                         // Cредняя точность
    var gamesCount: Int { get }                                 // Количество завершенных игр
    var bestGame: GameRecord { get }                            // Рекорд
}

class StatisticServiceImplementation: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard            // Сокращение для удобства

    private enum Keys: String {                                 // Ключи для сохранения в User Defaults через enum, у кейсов берется rawValue
        case correct, total, bestGame, gamesCount, totalAccuracy// Ключи всех сущностей
    }
    
    /// Запись данных ограничена извне через протокол (get / set). Без протокола ограничение достигается за счёт модификаторов доступа класса (private(set) bestGame: GameRecord).
    var bestGame: GameRecord {
        get {
            /// Читаем userDefaults.data (из ПЗУ) собирая данные по ключам enum'а (rawValue)
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  // Метод автоматически раскладывает полученные данные в структуру GameRecord в тип ?
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                // Возвращаем полученные значения и задаем им тип данных?
                return .init(correct: 0, total: 0, date: "")
            }
            return record
        }
        set {
            /// Преобразовываем структуру GameRecord в Data (через метод JSONEncoder)
            /// В сеттере структура будет лежать в переменной newValue и её необходимо записать в User Defaults.
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            /// Запись значения:  полученную переменную userDefaults.data (в ПЗУ)  сохраняем в User Defaults
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var currentAccuracy: Double = 0                                 // Текущая за игру
    var averageAccuracy: Double {                                   // Средняя за все игры
        get { return totalAccuracy/Double(gamesCount) }
    }
    var totalAccuracy: Double {                                     // Общая за все игры
        
        get { userDefaults.double(forKey: Keys.totalAccuracy.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)  }
    }
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    // Функция сохранения лучшего результата,с проверкой что он лучше чем в UserDefaults
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1         // Повышаем кол-во сыгранных игр
        currentAccuracy = (Double(count)/Double(amount))*100.0
        totalAccuracy = (totalAccuracy + currentAccuracy)
        
        let date: Date = Date()
        let currentGameRecord = GameRecord(correct: count, total: amount, date: date.dateTimeString)
        let lastGamesRecord = bestGame
        if lastGamesRecord.correct < currentGameRecord.correct {
            bestGame = currentGameRecord
        }
    }
}
