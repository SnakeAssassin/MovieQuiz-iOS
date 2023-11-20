//
//  ArrayTest.swift
//  MovieQuizTests
//
//  Created by Joe Kramer on 16.11.2023.
//

import XCTest

/// Импортируем приложение для тестирования
@testable import MovieQuiz

final class ArrayTest: XCTestCase {
    /// Тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        let array = ["a", "b", "c", "d", "e"]
        // When
        let value = array[safe: 2]
        // Then
        print(value as Any)
        XCTAssertNotNil(value)      // Значение не пустое
        XCTAssertEqual(value, "c")  // И вернуло "c"
    }
    
    /// Тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 20]
        // Then
        XCTAssertNil(value)         // Вернуло nil
    }
    
}
