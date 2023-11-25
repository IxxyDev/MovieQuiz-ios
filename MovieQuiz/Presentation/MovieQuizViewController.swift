import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        posterImageView.layer.cornerRadius = 20
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func show(quiz step: QuizStepViewModel) {
        posterImageView.layer.borderColor = UIColor.clear.cgColor
        posterImageView.image = step.image
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showQuizResult(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        let completion = {
            self.presenter.restartGame()
        }
        
        let alert = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: completion
        )
        
        let alertPresenter = AlertPresenter(alert: alert, viewController: self)
        alertPresenter.showQuizResult()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        
        let alertPresenter = AlertPresenter(alert: alert, viewController: self)
        alertPresenter.showQuizResult()
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
}
