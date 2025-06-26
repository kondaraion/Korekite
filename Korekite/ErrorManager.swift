import Foundation
import SwiftUI

class ErrorManager: ObservableObject {
    @Published var currentError: ErrorInfo?
    @Published var showingError = false
    
    func showError(_ error: ErrorInfo) {
        currentError = error
        showingError = true
    }
    
    func clearError() {
        currentError = nil
        showingError = false
    }
}

struct ErrorInfo {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
}

// MARK: - Error View Modifier

struct ErrorAlert: ViewModifier {
    @ObservedObject var errorManager: ErrorManager
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorManager.currentError?.title ?? "エラー",
                isPresented: $errorManager.showingError,
                presenting: errorManager.currentError
            ) { error in
                if let actionTitle = error.actionTitle, let action = error.action {
                    Button(actionTitle, action: action)
                }
                Button("OK") {
                    errorManager.clearError()
                }
            } message: { error in
                Text(error.message)
            }
    }
}

extension View {
    func errorAlert(_ errorManager: ErrorManager) -> some View {
        modifier(ErrorAlert(errorManager: errorManager))
    }
}