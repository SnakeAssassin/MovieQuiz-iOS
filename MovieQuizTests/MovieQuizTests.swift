//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Joe Kramer on 15.11.2023.
//

import XCTest

/// Добавляем задержку ответа вычисляемой функции
struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
}


final class MovieQuizTests: XCTestCase {
    
    func testAddition() throws {
        // Given / Дано
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        
        // When / Когда
        // Создаем объект ожидания и задаем для него описание
        let expectation = expectation(description: "Addition function expectation")
        
        arithmeticOperations.addition(num1: num1, num2: num2) { result in
            // Then / Тогда
            XCTAssertEqual(result, 3)
            
            // Теперь, когда операция завершена, мы уведомляем XCTest о завершении ожидания
            expectation.fulfill()
        }
        // Ожидание завершения асинхронной операции не более 2 секунд
        waitForExpectations(timeout: 2)
    }
}
