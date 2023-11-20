import UIKit

/// Подписываем класс на протокол делегата
final class MovieQuizViewController: UIViewController {
    
    // MARK: - Variables
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent } // Светлый статус-бар
    //
    
    /*private var questionFactory: QuestionFactoryProtocol?       // Инъекция через свойство делегата фабрики вопросов, в контроллере создаем экземпляр questionFactory с типом протокола QuestionFactoryProtocol*/
    private var statisticService: StatisticServiceProtocol?     // Экземпляр класса StatisticServiceImplementation, реализующего протокол StatisticServiceProtocol
    private var presenter: MovieQuizPresenter!                // Экземпляр MVP
    
    // MARK: - Lifecycle
    /// Изображение создано и готово к показу: "Вопрос показан"
    override func viewDidLoad() {
        super.viewDidLoad()
        /*questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)        // Связывает делегат questionFactory с viewDidLoad()*/
        statisticService = StatisticServiceImplementation()     // Заполняем statisticService после инициализации
        showLoadingIndicator()                                  // Показываем индикатор загрузки
        /*questionFactory?.loadData()                             // Начинаем загрузку данных*/
        //questionFactory?.requestNextQuestion()                   // Отображение первого вопроса
        presenter = MovieQuizPresenter(viewController: self)             // Передаем текущий ViewController презентеру
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
        presenter.yesButtonClicked()
        lockYesNoButtons(isEnable: true)
    }
    
    /// Обработчик нажатия кнопки "Нет", кнопка блокируется при повторном нажатии
    /// После нажатия передает ответ в метод showAnswerResult
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        lockYesNoButtons(isEnable: true)
        presenter.noButtonClicked()
    }
    
    
    // MARK: - QuestionFactoryDelegate`
    
    
    
    
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
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Скрытие индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    /*/// Алерт о состоянии ошибки при вызове URL-запроса или получении errorMesage от API
    private func showNetworkError(message: String) {
        showLoadingIndicator()
        
        let completion = {
            self.presenter.restartGame()
            /*self.questionFactory?.loadData()*/
        }
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: completion)
        
        show(quiz: alertModel)
    }*/
    
    /// Вызов алерта: Сообщение об ошибке загрузки
    /*func didFailToLoadData(with error: Error) {
        /// Передаем описание ошибки error через NSError в Алерт презентер
        showNetworkError(message: error.localizedDescription)
    }*/
    
    /*/// Вызов алерта: Сообщение об ошибки от API
    func didLoadErrorFromAPI(with errorMessage: String) {
        /// Передаем ошибку в Алерт презентер
        showNetworkError(message: errorMessage)
    }*/
    
    /// Сообщение об успешной загрузке
    /*func didLoadDataFromServer() {
        activityIndicator.isHidden = true       // Скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()  // Выводим вопрос
    }*/
    
    /// Добавляем метод для удовлетворения требований подписки на протокол QuestionFactoryDelegate
    /// Фабрика отдает question в Delegate, MVC реализует протокол Delegate, поэтому содержит этот метод, а в методе вызывается метод презентера
    /// QuestionFactory -> QuestionFactoryDelegate -> MovieQuizViewController -> MovieQuizPresenter
    /*func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }*/
    
    /// Показать ответ и перейти к следующему вопросу
    internal func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrect: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.statisticService = self.statisticService
            /*self.presenter.questionFactory = self.questionFactory*/
            self.presenter.showNextQuestionOrResults()
            
            self.lockYesNoButtons(isEnable: false)
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
       
    /// Конвертирует QuizStepViewModel -> UIViewController
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// Вывод данных через Алерт презентер
    func show(quiz result: AlertModel) {

        let alertModel = AlertModel(
            title: result.title,
            message: result.message,
            buttonText: result.buttonText,
            completion: result.completion)
        
        let alertPresenter = AlertPresenter(alertModel: alertModel, viewController: self)
        alertPresenter.showAlert()
    }
    
    

}
