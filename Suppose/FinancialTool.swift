import SwiftUI

enum FinancialTool: String, CaseIterable, Identifiable {
    case investment

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .investment:
            "Suppose Investment"
        }
    }

    var subtitle: String {
        switch self {
        case .investment:
            "Project annual investment balances from a starting value, monthly contribution, return, and age."
        }
    }

    var symbolName: String {
        switch self {
        case .investment:
            "chart.line.uptrend.xyaxis"
        }
    }
}
