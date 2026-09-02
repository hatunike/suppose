import SwiftUI

enum FinancialTool: String, CaseIterable, Identifiable {
    case investment
    case mortgage

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .investment:
            "Suppose Investment"
        case .mortgage:
            "Mortgage"
        }
    }

    var subtitle: String {
        switch self {
        case .investment:
            "Project annual investment balances from a starting value, monthly contribution, return, and age."
        case .mortgage:
            "See each year until payoff from your balance, rate, and payment, and how an additional payment speeds it up."
        }
    }

    var symbolName: String {
        switch self {
        case .investment:
            "chart.line.uptrend.xyaxis"
        case .mortgage:
            "house.fill"
        }
    }
}
