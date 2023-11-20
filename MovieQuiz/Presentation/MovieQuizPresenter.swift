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
    
    let questionAmount: Int = 10                        // Общее количество вопросов для квиза
    private var currentQuestionIndex = 0                // Переменная с индексом текущего вопроса
    
    internal var currentQuestion: QuizQuestion?          // Вопрос, который видит пользователь
    weak var viewController: MovieQuizViewController?   // Слабая ссылка на View
    
    internal var correctAnswers = 0                              // Переменная со счетчиком правильных ответов
 
    private var questionFactory: QuestionFactoryProtocol?
    internal var statisticService: StatisticServiceProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        viewController.hideLoadingIndicator()
    }
    
    // MARK: QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
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
    
    /// Добавляем метод для удовлетворения требований подписки на протокол QuestionFactoryDelegate
    /// Класс контроллера подписан на протокол делегата фабрики QuestionFactoryDelegate и реализует метод протокола didReceiveNextQuestion(question: QuizQuestion?)
    /// /Фабрика отдает question в Delegate, MVP реализует протокол Delegate, поэтому содержит этот метод и вызывается этот метод
    /// QuestionFactory -> QuestionFactoryDelegate -> MovieQuizPresenter
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        /// UI обязательно обновляется из главного потока, но так как фабрика грузит вопросы из сети
        /// поэтому указываем вызов метода didReceiceNextQuestion  в главном потоке
        /// В случае с DispatchQueue.main использование [weak self] некритично из-за особенностей работы главного потока. Значит, вы можете добавлять [weak self] везде, где есть self.
        DispatchQueue.main.async { [weak self] in   // Если в замыкании есть self, то нужно использовать слабую ссылку
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    
    
    
    // MARK: Functions
    
    /// Сброс счетчика вопросов
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        //questionFactory?.loadData()    // !!
    }
    
    /// Проверка что вопрос последний
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    
    /// Следующий вопрос
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// Конвертирует QuizQuestion -> QuizStepViewModel
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
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    

        
    /// Показать следующий вопрос или вывести результат
    internal func showNextQuestionOrResults() {
        /// Если все вопросы показаны – выводим Алерт
        if self.isLastQuestion() {
            //
            if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: questionAmount)
                
                let completion = {
                    self.restartGame()
                    
                    self.questionFactory?.requestNextQuestion()
                }
                
                let text = """
                Ваш результат: \(correctAnswers)/\(questionAmount)\nКоличество сыграных квизов: \(statisticService.gamesCount)\n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date) \n Средняя точность: \(String(format: "%.2f", statisticService.averageAccuracy))%
                """
                
                let viewModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: text,
                    buttonText: "Сыграть ещё раз",
                    completion: completion)
                viewController?.show(quiz: viewModel)
            }
            /// Если не последний вопрос, то показываем следующий следующий вопрос от Фабрики вопросов
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    
    
    
}
