import SwiftUI

enum FinancialTool: String, CaseIterable, Identifiable {
    case investment
    case mortgage
    case contributionRoom
    case withdrawalRate

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
        case .withdrawalRate:
            "Withdrawal Rate"
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
        case .withdrawalRate:
            "Look up what a withdrawal rate pays out at a given net worth, and its historical 30-year failure rate."
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
        case .withdrawalRate:
            "percent"
        }
    }
}
