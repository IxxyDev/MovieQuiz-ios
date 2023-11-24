import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: String
    
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    var avgAccuracy: Double { get }
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
    
    var currentAccuracy: Double = 0
    var gamesCount: Int = 0
    
    var totalAccuracy: Double {
        get { userDefaults.double(forKey: Keys.totalAccuracy.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue) }
    }
    
    var avgAccuracy: Double {
        get { return totalAccuracy / Double(gamesCount) }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: "")
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        currentAccuracy = (Double(count) / Double(amount)) * 100.0
        totalAccuracy += currentAccuracy
        
        let date: Date = Date()
        let currentGameRecord = GameRecord(correct: count, total: amount, date: date.dateTimeString)
        let lastGamesRecord = bestGame
        if currentGameRecord.isBetterThan(lastGamesRecord) {
            bestGame = currentGameRecord
        }
    }
}
