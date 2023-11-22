import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionsFactoryDelegate?
//    private lazy var questions: [QuizQuestion] = [
//        QuizQuestion(image: "The Green Elephant", text: questionLabel, isCorrectAnswer: true),
//        QuizQuestion(image: "Pyat butylok vodki", text: questionLabel, isCorrectAnswer: true),
//        QuizQuestion(image: "Vase de noces", text: questionLabel, isCorrectAnswer: false),
//        QuizQuestion(image: "Srpski film", text: questionLabel, isCorrectAnswer: true),
//        QuizQuestion(image: "Neposredstvenno Kakha", text: questionLabel, isCorrectAnswer: false),
//        QuizQuestion(image: "The Best Movie", text: questionLabel, isCorrectAnswer: false),
//        QuizQuestion(image: "Lords of the Lockerroom", text: questionLabel, isCorrectAnswer: true),
//        QuizQuestion(image: "The Room", text: questionLabel, isCorrectAnswer: false),
//        QuizQuestion(image: "Schastlivyy konets", text: questionLabel, isCorrectAnswer: false),
//        QuizQuestion(image: "Sharknado", text: questionLabel, isCorrectAnswer: false),
//    ]
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionsFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let idx = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: idx] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let ratingForQuestion: Float = [rating - 1, rating + 1].randomElement() ?? 0.0
            let text = "Рейтинг этого фильма больше чем \(Int(ratingForQuestion))?"
            let correctAnswer = rating > ratingForQuestion
            
            let question = QuizQuestion(image: imageData, text: text, isCorrectAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
