//
//  MoviesLoaderTest.swift
//  MovieQuizTests
//
//  Created by Joe Kramer on 16.11.2023.
//

import XCTest
@testable import MovieQuiz

final class MoviesLoaderTest: XCTestCase {
    func testSuccessLoading() throws {
        // Given
        // Создаем экземпляр стаба NetworkClient
        let stubNetworkClient = StubNetworkClient(emulateError: false) // говорим, что не хотим эмулировать ошибку
        // Создаем экземпляр загрузчика и указываем
        
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                // Сравниваем данные с тем, что мы ожидали
                // давайте проверим, что пришло, например, два фильма — ведь в тестовых данных их всего два
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                // Не ожидаем ошибку, но если она есть – провалить тест
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true) // говорим, что хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success(_):
                XCTFail("Fail")
            }
            
        }
        waitForExpectations(timeout: 1)
    }
}
