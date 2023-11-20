//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Joe Kramer on 18.11.2023.
//

import XCTest

@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    /// Примитив приложения, переменная символизирует приложение, которое мы тестируем
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        /// Инициализация приложения в момент использования
        app = XCUIApplication()
        /// Метод откроет приложение
        app.launch()
        
        /// Если один тест провалился, то следующий тест не будет запускаться
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        /// Метод закроет приложение
        app.terminate()
        /// Обнуляем значение переменной
        app = nil
    }

    /// Код теста
    
    func testYesButton() {
        /// Задержка для загрузки данных JSON
        sleep(3)
        /// Находим первоначальный постер по AccessibilityIdentifier идентификатору
        let firstPoster = app.images["Poster"]
        /// Делаем скриншот UI-элемента Poster и сохраняем байты в переменную
        /// Вычисляемое свойство pngRepresentation возвращает нам скриншот в виде данных (тип Data).
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        
        // Нажимаем на кнопку по AccessibilityIdentifier идентификатору
        app.buttons["Yes"].tap()
        
        // Задержка для загрузки второй картинки из сети
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        
        // Считываем номер вопроса
        let indexLabel = app.staticTexts["Index"]
        
        // Проверяем, что постеры имеют разный вес с точностью до байта
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        /// Проверяем соответствие текста через свойство indexLabel.label
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        /// Задержка для загрузки данных JSON
        sleep(3)
        /// Находим первоначальный постер по AccessibilityIdentifier идентификатору
        let firstPoster = app.images["Poster"]
        /// Делаем скриншот UI-элемента Poster и сохраняем байты в переменную
        /// Вычисляемое свойство pngRepresentation возвращает нам скриншот в виде данных (тип Data).
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        
        // Нажимаем на кнопку по AccessibilityIdentifier идентификатору
        app.buttons["No"].tap()
        
        // Задержка для загрузки второй картинки из сети
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        
        // Считываем номер вопроса
        let indexLabel = app.staticTexts["Index"]
        
        // Проверяем, что постеры имеют разный вес с точностью до байта
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        /// Проверяем соответствие текста через свойство indexLabel.label
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
   
    
    func testAlertEndGame() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["Alert"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testNewGame() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["Alert"]
        
        XCTAssertTrue(alert.exists)
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")

    }
    
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
