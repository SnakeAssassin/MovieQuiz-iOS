//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Joe Kramer on 20.11.2023.
//

import UIKit

/// MVP
final class MovieQuizPresenter: QuestionFactoryDelegate {

    // MARK: Variables
    
    private let statisticService: StatisticServiceProtocol!
    // Экземпляр questionFactory, инъекция через свойство делегата фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // Переменная пассивного ViewController
    private weak var viewController: MovieQuizViewControllerProtocol?
    // Вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    // Общее количество вопросов для квиза
    private let questionAmount: Int = 10
    // Переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0
    // Cчетчик правильных ответов
    private var correctAnswers = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        viewController.hideLoadingIndicator()
    }
    
    
    // MARK: QuestionFactoryDelegate
    
    /// Сообщение об успешной загрузке
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    /// Вызов алерта: Сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    /// Вызов алерта: Сообщение об ошибки от API
    func didLoadErrorFromAPI(with errorMessage: String) {
        /// Передаем ошибку в Алерт презентер
        showNetworkError(message: errorMessage)
    }
    
    /// Алерт о состоянии ошибки при вызове URL-запроса или получении errorMesage от API
    private func showNetworkError(message: String) {
        viewController?.showLoadingIndicator()
        
        let completion = {
            self.restartGame()
            self.questionFactory?.loadData()
        }
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: completion)
        
        self.viewController?.show(quiz: alertModel)
    }
    
    /// Фабрика возвращает рандомный вопрос через делегат
    /// QuestionFactory -> QuestionFactoryDelegate -> MovieQuizPresenter
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: Methods
    
    /// Сброс статистики текущей игры
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    /// Проверка что вопрос последний
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    
    /// Подсчет пройденных вопросов
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// Конвертор QuizQuestion -> QuizStepViewModel
    internal func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    /// Нажата кнопка "Нет"
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    /// Нажата кнопка "Нет"
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    /// Принять ответ, вывести результат и показать следующий экран
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    /// Подсчет правильных ответов
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    /// Переход к следующему вопросу или вывод результата
    internal func proceedToNextQuestionOrResults() {
        /// Если все вопросы показаны – выводим Алерт
        if self.isLastQuestion() {
                let completion = {
                    self.restartGame()
                    self.questionFactory?.requestNextQuestion()
                }
                
                let text = makeResultsMessage()
                
                let viewModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: text,
                    buttonText: "Сыграть ещё раз",
                    completion: completion)
                viewController?.show(quiz: viewModel)
        /// Если не последний вопрос, то показываем следующий следующий вопрос от Фабрики вопросов
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    /// Сбор статистических данных
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionAmount)
        
        let bestGame = statisticService.bestGame
        
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date)"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.averageAccuracy))%"
        
        let resultMessage = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    /// Вывод правильного ответа и переход к следующему
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}
