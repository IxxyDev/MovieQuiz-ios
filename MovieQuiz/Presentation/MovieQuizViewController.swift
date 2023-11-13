import UIKit

final class MovieQuizViewController: UIViewController, QuestionsFactoryDelegate {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticSerivce: StatisticService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        statisticSerivce = StatisticServiceImplementation()
        
        toggleButtonsState(isEnabled: true)
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.cornerRadius = 20
        
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = self.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if (currentQuestion.isCorrectAnswer) {
            showAnswerResult(isCorrect: true)
            correctAnswers += 1;
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction private func noButtonCicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if (currentQuestion.isCorrectAnswer) {
            showAnswerResult(isCorrect: false)
        } else {
            showAnswerResult(isCorrect: true)
            correctAnswers += 1;
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel.init(
            image: UIImage.init(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber:  "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        
        return quizStepViewModel
    }
    
    private func show(quiz step: QuizStepViewModel) {
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
        posterImageView.image = step.image
    }
    
    private func showQuizResult(quiz result: QuizResultsViewModel) {
        let completion = {
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: completion
        )
        
        let alertPresenter = AlertPresenter(alert: alert, viewController: self)
        alertPresenter.showQuizResult()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.posterImageView.layer.borderWidth = 0
            self.toggleButtonsState(isEnabled: false);
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        toggleButtonsState(isEnabled: true)
        
        if currentQuestionIndex == questionsAmount - 1 {
            if let statisticService = statisticSerivce {
                statisticSerivce?.store(correct: correctAnswers, total: questionsAmount)
                
                let alertText = """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Количество сыграных квизов: \(statisticService.gamesCount)
                        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date)
                        Средняя точность: \(String(format: "%.2f", statisticService.avgAccuracy))%
                """
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен",
                    text: alertText,
                    buttonText: "Сыграть ещё раз"
                )
                showQuizResult(quiz: viewModel)
            }
        } else {
            currentQuestionIndex += 1;
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func toggleButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled;
        noButton.isEnabled = isEnabled;
    }
 }
