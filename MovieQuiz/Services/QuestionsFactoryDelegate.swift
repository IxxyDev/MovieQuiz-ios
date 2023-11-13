import Foundation

protocol QuestionsFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
