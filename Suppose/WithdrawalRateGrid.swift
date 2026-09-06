import Foundation

/// The reference grid: net worth rows crossed with withdrawal-rate columns.
enum WithdrawalRateGrid {
    /// Net worth rows, in flat $100k steps from $300k to $10m.
    static let netWorths: [Double] = Array(stride(from: 300_000.0, through: 10_000_000.0, by: 100_000.0))

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

    // SEEDED APPROXIMATE MODEL — not derived from a dataset. Extends the failure-rate
    // table above (which stays the anchor at 0%) to other ending-balance thresholds by
    // modeling the surviving (non-failed) outcomes as centered on a rough "typical"
    // ending balance that falls as the withdrawal rate rises, with a logistic spread
    // around it. Only meant to be directionally sensible pending real verification.
    private static let survivorModels: [PortfolioAllocation: SurvivorDistributionModel] = [
        .sixtyForty: SurvivorDistributionModel(medianAt325: 320, medianAt500: 140, spread: 70),
        .seventyFiveTwentyFive: SurvivorDistributionModel(medianAt325: 380, medianAt500: 160, spread: 85),
        .allStock: SurvivorDistributionModel(medianAt325: 420, medianAt500: 170, spread: 100),
    ]

    /// The historical chance (%) that a 30-year retirement ends with a balance at or
    /// below `threshold` (as a percentage of the original balance) at `ratePercent`.
    /// `.ranOut` (0%) uses the seeded failure-rate table directly; other thresholds
    /// layer the approximate survivor model on top of that same failure rate.
    func chanceEndingBalance(atOrBelow threshold: BalanceThreshold, forWithdrawalRate ratePercent: Double) -> Int {
        let failure = Double(failureRatePercent(forWithdrawalRate: ratePercent))
        guard threshold != .ranOut, let model = Self.survivorModels[self] else { return Int(failure.rounded()) }
        let survivorChance = model.cumulativeChance(atOrBelow: Double(threshold.rawValue), forWithdrawalRate: ratePercent)
        let combined = failure + (100 - failure) * survivorChance
        return Int(min(100, max(0, combined)).rounded())
    }

    /// The historical chance (%) that a 30-year retirement's ending balance compares
    /// to `threshold` as `direction` says — e.g. `.atOrAbove` at 100% is the chance of
    /// at least breaking even. `.atOrAbove` is the complement of `.atOrBelow`.
    func chanceEndingBalance(_ direction: ComparisonDirection, threshold: BalanceThreshold, forWithdrawalRate ratePercent: Double) -> Int {
        let atOrBelow = chanceEndingBalance(atOrBelow: threshold, forWithdrawalRate: ratePercent)
        switch direction {
        case .atOrBelow: return atOrBelow
        case .atOrAbove: return 100 - atOrBelow
        }
    }
}

/// Which side of a `BalanceThreshold` a grid cell's revealed percentage represents.
enum ComparisonDirection: String, CaseIterable, Identifiable, Hashable {
    case atOrBelow
    case atOrAbove

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .atOrBelow: "≤"
        case .atOrAbove: "≥"
        }
    }

    mutating func toggle() {
        self = self == .atOrBelow ? .atOrAbove : .atOrBelow
    }
}

/// A target ending balance, as a percentage of the original starting balance, that a
/// grid cell's revealed percentage represents the historical chance of landing at or below.
enum BalanceThreshold: Int, CaseIterable, Identifiable, Hashable {
    case ranOut = 0
    case twentyFive = 25
    case fifty = 50
    case seventyFive = 75
    case oneHundred = 100
    case oneTwentyFive = 125
    case oneFifty = 150
    case oneSeventyFive = 175
    case twoHundred = 200

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .ranOut: "Ran out (0%)"
        case .oneHundred: "100% (break-even)"
        case .twoHundred: "200% (doubled)"
        default: "\(rawValue)%"
        }
    }
}

/// A rough logistic model of where the surviving (non-failed) 30-year outcomes land,
/// as a percentage of the original balance. `medianAt325`/`medianAt500` are the assumed
/// typical ending balance at the low and high ends of the withdrawal-rate range, linearly
/// interpolated in between; `spread` controls how quickly probability ramps around that median.
private struct SurvivorDistributionModel {
    let medianAt325: Double
    let medianAt500: Double
    let spread: Double

    func medianEndingBalance(forWithdrawalRate ratePercent: Double) -> Double {
        let t = (ratePercent - 3.25) / (5.00 - 3.25)
        return medianAt325 + (medianAt500 - medianAt325) * t
    }

    func cumulativeChance(atOrBelow threshold: Double, forWithdrawalRate ratePercent: Double) -> Double {
        let median = medianEndingBalance(forWithdrawalRate: ratePercent)
        let z = (threshold - median) / spread
        return 1 / (1 + exp(-z))
    }
}
