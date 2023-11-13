import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionsFactoryDelegate?
    private let questionLabel = "Рейтинг этого фильма больше чем 5?"
    private lazy var questions: [QuizQuestion] = [
        QuizQuestion(image: "The Green Elephant", text: questionLabel, isCorrectAnswer: true),
        QuizQuestion(image: "Pyat butylok vodki", text: questionLabel, isCorrectAnswer: true),
        QuizQuestion(image: "Vase de noces", text: questionLabel, isCorrectAnswer: false),
        QuizQuestion(image: "Srpski film", text: questionLabel, isCorrectAnswer: true),
        QuizQuestion(image: "Neposredstvenno Kakha", text: questionLabel, isCorrectAnswer: false),
        QuizQuestion(image: "The Best Movie", text: questionLabel, isCorrectAnswer: false),
        QuizQuestion(image: "Lords of the Lockerroom", text: questionLabel, isCorrectAnswer: true),
        QuizQuestion(image: "The Room", text: questionLabel, isCorrectAnswer: false),
        QuizQuestion(image: "Schastlivyy konets", text: questionLabel, isCorrectAnswer: false),
        QuizQuestion(image: "Sharknado", text: questionLabel, isCorrectAnswer: false),
    ]
    
    init(delegate: QuestionsFactoryDelegate? = nil) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
