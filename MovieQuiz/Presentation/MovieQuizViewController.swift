import UIKit

/// Подписываем класс на протокол делегата
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {


    // MARK: - Переменные
    
    /// Переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0
    /// Переменная со счетчиком правильных ответов
    private var correctAnswers = 0
    /// Общее количество вопросов для квиза
    private let questionAmount: Int = 10
    /// Инъекция через свойство делегата фабрики вопросов, в контроллере создаем экземпляр questionFactory с типом протокола QuestionFactoryProtocol
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    /// Вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    
    /// Инъекция Алерт презентера в ViewController
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    
    // Наполнение алерт-модели данными
    private var alertModel = AlertModel(title: "Этот раунд окончен!", message: "", buttonText: "Играть еще раз!")
    
    // Описание работы делегата, который будет вызван из кода AlertPresenter
    internal func didReceiveAlert() {
        self.currentQuestionIndex = 0                               // Обнуляем номер текущего вопроса
        self.correctAnswers = 0                                     // Сбрасываем переменную с количеством правильных ответов
        questionFactory?.requestNextQuestion()                      // Запрос нового вопроса через QuestionFactory
    }
    
    
    
  
    
    // MARK: - Методы
    /// Приватный метод конвертации
    /// Метод принимает моковый запрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
            return questionStep
    }
    
    
    /// Приватный метод, который предотвращает повторное нажатие любой кнопки выбора ответа
    /// Метод принимает на вход булевое значение и ничего не возвращает
    private func lockYesNoButtons(isEnable: Bool) {
        if isEnable == true {
            yesButton.isEnabled = false
            noButton.isEnabled = false
        } else {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
 
    /// Приватный метод, который меняет цвет рамки в зависимости от правильности ответа и выводит следующий вопрос или результат
    /// Метод принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Переход на следующий вопрос через 1с, скрытие рамки, разблокировка кнопок
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.lockYesNoButtons(isEnable: false)
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    
    /// Приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и задает данные для отображения UI
    /// Метод принимает принимает на вход вью модель вопроса и задает данные для отображения UI и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {                           // show - название метода; quiz – метка (название) параметра;
                                                                                // step – экземпляр структуры; QuizStepModel – структура;
        imageView.image = step.image                                            // Задаем название изображения афиши для объекта UIImageView
        textLabel.text = step.question                                          // Задаем текст вопроса для UILabel
        counterLabel.text = step.questionNumber                                 // Задаем номер вопроса для UILabel
    }
    

    /// Метод вывода следующего вопроса или вывода алерта, если вопрос последний (метод ничего не принимает и не возвращает
    private func showNextQuestionOrResults() {
        /// Если текущий индекс вопроса равен последнему в массиве, то выводим "Результат квиза" через системный Алерт презентер
        if currentQuestionIndex == questionAmount - 1 {
            alertModel.message = "Ваш результат: \(correctAnswers)/\(questionAmount)"
            self.alertPresenter?.restartGame(model: alertModel, viewController: self, completion: nil)
        /// Если не последний вопрос, то показываем следующий следующий вопрос от Фабрики вопросов
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    


    // MARK: - Аутлеты
    /// Связи аутлетов изображений, текста вопросов и счетчика вопросов
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    
    
    // MARK: - Действия
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
    
    
    // MARK: - Lifecycle
    /// Изображение создано и готово к показу: "Вопрос показан"
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory?.delegate = self                                            // Связывает делегат questionFactory с viewDidLoad()
        questionFactory?.requestNextQuestion()                                      // Отображение первого вопроса
        alertPresenter?.delegate = self                                                      // Связывает делегат alertPresenter с viewDidLoad()
        alertPresenter?.restartGame(model: alertModel, viewController: self, completion: nil)// Передает данные для наполнения алерта
    }
    
    ///  Настройка статус-бара
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    
    
    /// Добавляем метод для удовлетворения требований подписки на протокол QuestionFactoryDelegate
    /// Класс контроллера подписан на протокол делегата фабрики QuestionFactoryDelegate и реализует метод протокола didReceiveNextQuestion(question: QuizQuestion?)
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
            self?.show(quiz: viewModel)
        }
    }
}
