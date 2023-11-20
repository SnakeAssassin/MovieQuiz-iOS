import UIKit

/// Подписываем класс на протокол делегата
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Variables
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent } // Светлый статус-бар
    //
    
    private var correctAnswers = 0                              // Переменная со счетчиком правильных ответов
    
    
    private var currentQuestion: QuizQuestion?                  // Вопрос, который видит пользователь
    private var questionFactory: QuestionFactoryProtocol?       // Инъекция через свойство делегата фабрики вопросов, в контроллере создаем экземпляр questionFactory с типом протокола QuestionFactoryProtocol
    private var statisticService: StatisticServiceProtocol?     // Экземпляр класса StatisticServiceImplementation, реализующего протокол StatisticServiceProtocol
    private let presenter = MovieQuizPresenter()                // Экземпляр MVP
    
    // MARK: - Lifecycle
    /// Изображение создано и готово к показу: "Вопрос показан"
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)        // Связывает делегат questionFactory с viewDidLoad()
        statisticService = StatisticServiceImplementation()     // Заполняем statisticService после инициализации
        showLoadingIndicator()                                  // Показываем индикатор загрузки
        questionFactory?.loadData()                             // Начинаем загрузку данных
        //questionFactory?.requestNextQuestion()                   // Отображение первого вопроса
    }
    
    
    // MARK: - Outlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Actions
    /// Обработчик нажатия кнопки "Да", кнопка блокируется при повторном нажатии
    /// После нажатия передает ответ в метод showAnswerResult
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        lockYesNoButtons(isEnable: true)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    /// Обработчик нажатия кнопки "Нет", кнопка блокируется при повторном нажатии
    /// После нажатия передает ответ в метод showAnswerResult
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        lockYesNoButtons(isEnable: true)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    // MARK: - Delegates
    /// Добавляем метод для удовлетворения требований подписки на протокол QuestionFactoryDelegate
    /// Класс контроллера подписан на протокол делегата фабрики QuestionFactoryDelegate и реализует метод протокола didReceiveNextQuestion(question: QuizQuestion?)
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        /// UI обязательно обновляется из главного потока, но так как фабрика грузит вопросы из сети
        /// поэтому указываем вызов метода didReceiceNextQuestion  в главном потоке
        /// В случае с DispatchQueue.main использование [weak self] некритично из-за особенностей работы главного потока. Значит, вы можете добавлять [weak self] везде, где есть self.
        DispatchQueue.main.async { [weak self] in   // Если в замыкании есть self, то нужно использовать слабую ссылку
            self?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: - Private function
    
    /// Блокирует повторные нажатия
    private func lockYesNoButtons(isEnable: Bool) {
        if isEnable == true {
            yesButton.isEnabled = false
            noButton.isEnabled = false
        } else {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    /// Анимация индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Скрытие индикатора загрузки
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    /// Алерт о состоянии ошибки при вызове URL-запроса или получении errorMesage от API
    private func showNetworkError(message: String) {
        showLoadingIndicator()
        
        let completion = {
            self.questionFactory?.loadData()
        }
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: completion)
        
        show(quiz: alertModel)
    }
    
    /// Вызов алерта: Сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error) {
        /// Передаем описание ошибки error через NSError в Алерт презентер
        showNetworkError(message: error.localizedDescription)
    }
    
    /// Вызов алерта: Сообщение об ошибки от API
    func didLoadErrorFromAPI(with errorMessage: String) {
        /// Передаем ошибку в Алерт презентер
        showNetworkError(message: errorMessage)
    }
    
    /// Сообщение об успешной загрузке
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true       // Скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()  // Выводим вопрос
    }
    
    /// Показать ответ и перейти к следующему вопросу
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.lockYesNoButtons(isEnable: false)
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
       
    /// Конвертирует QuizStepViewModel -> UIViewController
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// Показать следующий вопрос или вывести результат
    private func showNextQuestionOrResults() {
        /// Если все вопросы показаны – выводим Алерт
        if presenter.isLastQuestion() {
            //
            if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: presenter.questionAmount)
                
                let completion = {
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
                
                let text = """
                Ваш результат: \(correctAnswers)/\(presenter.questionAmount)\nКоличество сыграных квизов: \(statisticService.gamesCount)\n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date) \n Средняя точность: \(String(format: "%.2f", statisticService.averageAccuracy))%
                """
                
                let viewModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: text,
                    buttonText: "Сыграть ещё раз",
                    completion: completion)
                show(quiz: viewModel)
            }
            /// Если не последний вопрос, то показываем следующий следующий вопрос от Фабрики вопросов
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    /// Вывод данных через Алерт презентер
    private func show(quiz result: AlertModel) {

        let alertModel = AlertModel(
            title: result.title,
            message: result.message,
            buttonText: result.buttonText,
            completion: result.completion)
        
        let alertPresenter = AlertPresenter(alertModel: alertModel, viewController: self)
        alertPresenter.showAlert()
    }
}
