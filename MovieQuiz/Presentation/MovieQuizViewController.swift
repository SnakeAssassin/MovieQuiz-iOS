import UIKit


final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - Variables
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent } // Светлый статус-бар
    private var presenter: MovieQuizPresenter!                // Экземпляр MVP
    
    
    // MARK: - Lifecycle
    /// Изображение создано и готово к показу: "Вопрос показан"
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)             // Передаем текущий ViewController презентеру
    }
    
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Actions
    
    /// Нажата кнопка "Yes"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        //lockYesNoButtons(isEnable: true)
        yesButton.isEnabled = false
        noButton.isEnabled = false
        presenter.yesButtonClicked()
    }
    
    /// Нажата кнопка "No"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        //lockYesNoButtons(isEnable: true)
        yesButton.isEnabled = false
        noButton.isEnabled = false
        presenter.noButtonClicked()
    }
    
    
    // MARK: - Private function
    
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
    
    /// Подсветка правильности ответа
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

       
    /// Конвертор QuizStepViewModel -> UIViewController
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// Вызов Алерта
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
