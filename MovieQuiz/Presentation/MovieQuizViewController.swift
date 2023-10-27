import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    
    // MARK: - Типы данных
    /// Структура для хранения информации о вопросе, изображении и правильном ответе.
    private struct QuizQuestion {
        // Строка с названием фильма совпадает с названием картинки афиши фильма в Assets
        let image: String
        // Строка с вопросом о рейтинге фильма
        let text: String
        // Булевое значение (true/false), правильный ответ на вопрос
        let correctAnswer: Bool
    }

    /// View-модель для состояния "Вопрос показан"
    private struct QuizStepViewModel {
        // Изображение с афишей фильма с типом UIImage
        let image: UIImage
        // Вопрос о рейтинге фильма
        let question: String
        // Порядковый номер вопроса (1/10)
        let questionNumber: String
    }
    
    /// View-модель для состояния "Результат квиза"
    private struct QuizResultsViewModel {
      // строка с заголовком алерта
      let title: String
      // строка с текстом о количестве набранных очков
      let text: String
      // текст для кнопки алерта
      let buttonText: String
    }
    
    
    
    // MARK: - Переменные
    /// Массив структур с данными вопросов
    private let questions: [QuizQuestion] = [QuizQuestion(image: "The Godfather",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "The Dark Knight",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "Kill Bill",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "The Avengers",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "Deadpool",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "The Green Knight",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: true),
                                             QuizQuestion(image: "Old",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false),
                                             QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false),
                                             QuizQuestion(image: "Tesla",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false),
                                             QuizQuestion(image: "Vivarium",
                                                          text: "Рейтинг этого фильма больше чем 6?",
                                                          correctAnswer: false)
    ]
    
    /// Переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0
    /// Переменная со счетчиком правильных ответов
    private var correctAnswers = 0
    
    
    
    // MARK: - Методы
    /// Приватный метод конвертации
    /// Метод принимает моковый запрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(                                   // Создаем экземпляр структуры QuizStepViewModel и заполняем значения
            image: UIImage(named: model.image) ?? UIImage(),                    // image типа UIImage заполняем, где named - имя изображения в ассете, в данном случае берем из структуры QuizQuestion.image  или, если вернулось nil, то показывает пустое изображение UIImage()
            question: model.text,                                               // Подставляем текст вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")   // Прибавляем к текущему значению вопроса 1 и отрисовываем общее кол-во вопросов в массиве (1/10)
        return questionStep                                                     // Возвращаем заполненный объект (экземпляр) структуры QuizStepViewModel
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
        if isCorrect {                                                          // Если ответ правильный
            correctAnswers += 1                                                 // Увеличиваем счетчик правильных ответов
        }
        
        // если есть скругления всегда imageView.layer.masksToBounds
        imageView.layer.masksToBounds = true                                    // определяет, будет ли обрезан контент, который выходит за границы слоя.
        imageView.layer.borderWidth = 8                                         // Толщина рамки
        imageView.layer.borderColor = isCorrect ?                               // Красим рамку, если isCorrect совпадает с правильным ответом в зеленый, если нет – в красный
            UIColor.ypGreen.cgColor :                                           // Тернарный оператор <условие> ? если да – <выражение 1> : если нет – <выражение 2>
            UIColor.ypRed.cgColor                                               // UIColor - расширение, ypGreen – цвет в расширении, cgColor – расширение для цвета
        
        // Запуск задачи через 1с с помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in  // [weak self] означает, что замыкание не повысит счетчик ссылок для переменной, а использует слабую ссылку
            guard let self = self else { return }                               // Разворачиваем слабую ссылку (если не пустой – присвоить, иначе return)
            // Вызываем метод перехода на следующий экран
            self.showNextQuestionOrResults()
            self.lockYesNoButtons(isEnable: false)                              // Сбрасываем блокировку кнопок ответа
            self.imageView.layer.borderColor = UIColor.clear.cgColor            // Убираем рамку после показа следующего вопроса
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
    
    
    /// Приватный метод для показа результатов раунда квиза через Алерт
    /// Принимает View-модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {

        /// 1. Создаём Алерт
        let alert = UIAlertController(                                      // Константа alert – хранит алерт
            title: result.title,                                            // Заголовок Алерта
            message: result.text,                                           // Текст Алерта
            preferredStyle: .alert)                                         // Тип алерта: может быть .alert или .actionSheet
        
        /// 2. Создаём кнопку с действием Алерта через замыкание, в котором пишем, что должно происходить при нажатии на кнопку
        /// константа action – хранит кнопку для Алерта
        /// title – текст кнопки
        /// style – .default: Обычная кнопка действия; .cancel: Кнопка, которая обозначает отмену текущего действия; .destructive: действие, которое может иметь разрушительные последствия (например, удаление чего-либо)
        /// Далее пишется выполняемый код после нажатия кнопки
        /// Мы пишем замыкания внутри класса, в нашем случае — внутри MovieQuizViewController. Поэтому, чтобы обратиться к полям и функциям этого класса из замыкания, Swift потребует написать self.  Так как это не просто общие параметры замыкания, а именно поля и функции класса.
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { [weak self] _ in                             // [weak self] означает, что замыкание не повысит счетчик ссылок для переменной, а использует слабую ссылку
                guard let self = self else { return }                       // Разворачиваем слабую ссылку (если не пустой – присвоить, иначе return)
                self.currentQuestionIndex = 0                               // Обнуляем номер текущего вопроса
                self.correctAnswers = 0                                     // Сбрасываем переменную с количеством правильных ответов
                // Запускаем стартовое вью
                let firstQuestion = self.questions[self.currentQuestionIndex] // Считываем данные первого вопроса в массиве
                let viewModel = self.convert(model: firstQuestion)          // Конвертируем данные для вью модели
                self.show(quiz: viewModel)                                  // Показываем вью с параметрами вопроса
            }
        
        /// 3. Добавляем в Алерт кнопку
        alert.addAction(action)
        
        /// 4. Показываем Алерт
        self.present(alert,
                     animated: true,
                     completion: nil)
    }
    
    
    /// Приватный метод, который содержит логику перехода в один из сценариев: 1) Показать следующий вопрос, 2) При показе последнего вопроса – показать Алерт с результатом
    /// Метод ничего не принимает и не возвращает
    private func showNextQuestionOrResults() {
        /// Если текущий индекс вопроса равен последнему в массиве, то выводим "Результат квиза" через системный Алерт
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(                               // Вызываем конструктор View-модели QuizResultsViewModel и заполняем данными
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questions.count)",    // Показываем кол-во правильных ответов из всех вопросов "3/10"
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)                                               // Показываем View-модель QuizResultsViewModel
        /// Если не последний вопрос, то показываем следующий следующий вопрос
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]                  // Высчитываем номер следующего вопроса
            let viewModel = convert(model: nextQuestion)                        // Конвертируем данные следующего вопроса для вью-модели
            show(quiz: viewModel)                                               // Показываем View-модель QuizStepViewModel
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
    /// Обработчик нажатия кнопки "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        lockYesNoButtons(isEnable: true)                                               // Блокируем повторное нажатие кнопок, после выбора ответа
        let currentQuestion = questions[currentQuestionIndex].correctAnswer       // Считываем правильный ответ
        let givenAnswer = true                                                    // Считываем ответ пользователя
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion)               // Сравниваем ответ пользователя с правильным и записываем результат в метод
    }
    
    /// Обработчик нажатия кнопки "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        lockYesNoButtons(isEnable: true)                                               // Блокируем повторное нажатие кнопок, после выбора ответа
        let currentQuestion = questions[currentQuestionIndex].correctAnswer       // Считываем правильный ответ
        let givenAnswer = false                                                   // Считываем ответ пользователя
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion)               // Сравниваем ответ пользователя с правильным и записываем результат в метод
    }
    
    
    // MARK: - viewDidLoad
    /// Изображение создано и готово к показу: "Вопрос показан"
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 1. Берём первый вопрос из массива вопросов по индексу текущего вопроса
        let currentQuestion = questions[currentQuestionIndex]                   // Начальное значение currentQuestionIndex = 0, т.е questions[0]
        /// 2. Конвертируем данные мокового запроса и возвращаем свойства в структуру View-модели типа QuizStepViewModel
        let questionOnScreen = convert(model: currentQuestion)                              // questionOnScreen – экзепляр структуры QuizStepViewModel
        /// 3. Выводим на экран UI-элементы со свойствами их View-модели
        show(quiz: questionOnScreen)                                                        // заполняем UI-элементы свойствами из View-модели
        
    }
    ///  Светлый стиль статус-бара
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default для темного статус-бара
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
