import SwiftUI

enum FinancialTool: String, CaseIterable, Identifiable {
    case investment
    case mortgage
    case contributionRoom

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .investment:
            "Investment"
        case .mortgage:
            "Mortgage"
        case .contributionRoom:
            "Contribution Room"
        }
    }

    var subtitle: String {
        switch self {
        case .investment:
            "Project annual investment balances from a starting value, monthly contribution, return, and age."
        case .mortgage:
            "See each year until payoff from your balance, rate, and payment, and how an additional payment speeds it up."
        case .contributionRoom:
            "See the 2026 tax-advantaged accounts a household can use and how much room each one has."
        }
    }

    var symbolName: String {
        switch self {
        case .investment:
            "chart.line.uptrend.xyaxis"
        case .mortgage:
            "house.fill"
        case .contributionRoom:
            "building.columns.fill"
        }
    }
}
