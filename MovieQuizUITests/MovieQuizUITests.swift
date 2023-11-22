//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Joe Kramer on 18.11.2023.
//

/// UI-тест MovieQuiz
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

    /// Тест работоспособности кнопки "Yes"
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
    
    /// Тест работоспособности кнопки "No"
    func testNoButton() {

        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()

        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    /// Тест появления Алерта
    func testAlertEndGame() {
        sleep(1)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        sleep(3)
        
        let alert = app.alerts["AlertIdentifier"]
        
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
        XCTAssertTrue(alert.exists)
    }
    
    /// Тест создания новой игры по нажатию на кнопку Алерта
    func testNewGame() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["AlertIdentifier"]
        
        XCTAssertTrue(alert.exists)
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
    // Тест производительности
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
