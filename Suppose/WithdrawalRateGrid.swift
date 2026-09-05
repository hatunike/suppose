import Foundation

/// The reference grid: net worth rows crossed with withdrawal-rate columns.
enum WithdrawalRateGrid {
    /// Net worth rows, graduated from $300k to $10m: $100k steps to $1m, $250k steps
    /// to $2m, $500k steps to $5m, then $1m steps to $10m.
    static let netWorths: [Double] = [
        300_000, 400_000, 500_000, 600_000, 700_000, 800_000, 900_000, 1_000_000,
        1_250_000, 1_500_000, 1_750_000, 2_000_000,
        2_500_000, 3_000_000, 3_500_000, 4_000_000, 4_500_000, 5_000_000,
        6_000_000, 7_000_000, 8_000_000, 9_000_000, 10_000_000,
    ]

    /// Withdrawal rates, as a percentage (4.00 means 4%), from 3.25% to 5.00%.
    static let withdrawalRates: [Double] = [3.25, 3.50, 3.75, 4.00, 4.25, 4.50, 4.75, 5.00]

    static func annualWithdrawal(netWorth: Double, ratePercent: Double) -> Double {
        netWorth * ratePercent / 100
    }
}

/// A stock/bond mix the historical failure-rate lookup is based on.
enum PortfolioAllocation: String, CaseIterable, Identifiable, Hashable {
    case sixtyForty
    case seventyFiveTwentyFive
    case allStock

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sixtyForty: "60/40"
        case .seventyFiveTwentyFive: "75/25"
        case .allStock: "100% Stocks"
        }
    }

    mutating func toggle() {
        switch self {
        case .sixtyForty: self = .seventyFiveTwentyFive
        case .seventyFiveTwentyFive: self = .allStock
        case .allStock: self = .sixtyForty
        }
    }

    // SEEDED VALUES — approximate historical success rates (%) for a 30-year, fixed
    // inflation-adjusted withdrawal from a rolling US-market backtest (Trinity-Study
    // style), keyed by withdrawal rate in basis points (400 = 4.00%). These are
    // interpolated from commonly cited reference points, NOT pulled from a specific
    // dataset — pending verification against a source like cFIREsim or ficalc.app
    // before being treated as authoritative.
    private static let successRatesByAllocation: [PortfolioAllocation: [Int: Int]] = [
        .sixtyForty: [325: 98, 350: 96, 375: 95, 400: 93, 425: 89, 450: 84, 475: 79, 500: 74],
        .seventyFiveTwentyFive: [325: 100, 350: 99, 375: 98, 400: 96, 425: 93, 450: 89, 475: 84, 500: 78],
        .allStock: [325: 99, 350: 98, 375: 97, 400: 95, 425: 91, 450: 86, 475: 80, 500: 74],
    ]

    /// The historical chance (%) that a 30-year retirement ran out of money at `ratePercent`.
    func failureRatePercent(forWithdrawalRate ratePercent: Double) -> Int {
        let basisPoints = Int((ratePercent * 100).rounded())
        let successRate = Self.successRatesByAllocation[self]?[basisPoints] ?? 0
        return 100 - successRate
    }
}
