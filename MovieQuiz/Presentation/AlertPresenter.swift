import UIKit

final class AlertPresenter {
    let alert: AlertModel
    weak var viewController: UIViewController?
    
    init(alert: AlertModel, viewController: UIViewController? = nil) {
        self.alert = alert
        self.viewController = viewController
    }
    
    func showQuizResult() {
        let alertUI = UIAlertController(
            title: alert.title, message: alert.message, preferredStyle: .alert
        )
        let action = UIAlertAction(title: alert.buttonText, style: .default) { _ in
            self.alert.completion()
        }
        
        guard let viewController = viewController else { return }
        alertUI.view.accessibilityIdentifier = "Game results"
        alertUI.addAction(action)
        viewController.present(alertUI, animated: true, completion: nil)
    }
}
