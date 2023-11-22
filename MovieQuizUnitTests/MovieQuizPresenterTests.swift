//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Joe Kramer on 22.11.2023.
//

/// Unit-тест для MovieQuizPresenter
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) { }
    func show(quiz result: AlertModel) { }
    func highlightImageBorder(isCorrect: Bool) { }
    func showLoadingIndicator() { }
    func hideLoadingIndicator() { }
}

/// Тест метода convert(model: QuizQuestion) -> QuizStepViewModel
final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}


