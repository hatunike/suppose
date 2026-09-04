import Foundation

/// One calendar year of a mortgage payoff schedule.
struct MortgageAmortizationYear: Identifiable, Equatable {
    let id: Int
    let year: Int
    let startingBalance: Double
    /// Scheduled principal paid during the year.
    let principalPaid: Double
    /// Interest paid during the year.
    let interestPaid: Double
    /// Additional (extra) principal paid during the year.
    let additionalPaid: Double
    let endingBalance: Double

    /// Scheduled principal plus additional principal paid during the year.
    var principalReduction: Double {
        principalPaid + additionalPaid
    }
}

/// A full payoff schedule for a `MortgageScenario`.
struct MortgageAmortization: Equatable {
    let years: [MortgageAmortizationYear]
    let monthsToPayoff: Int
    let totalInterest: Double
    /// Scheduled principal paid over the life of the loan.
    let scheduledPrincipal: Double
    /// Additional principal paid over the life of the loan.
    let additionalPrincipal: Double
    /// `false` when the inputs never bring the balance to zero.
    let isPaidOff: Bool

    var totalPaid: Double {
        totalInterest + scheduledPrincipal + additionalPrincipal
    }
}

/// The accelerated schedule alongside the schedule with no additional payment,
/// so the effect of the extra payment can be shown.
struct MortgagePayoffComparison: Equatable {
    let accelerated: MortgageAmortization
    let baseline: MortgageAmortization
    /// The additional monthly payment being compared against, so the opportunity-cost
    /// alternative (investing it instead) can be computed without re-deriving it from a scenario.
    let extraMonthlyPayment: Double

    var interestSaved: Double {
        max(0, baseline.totalInterest - accelerated.totalInterest)
    }

    var monthsSaved: Int {
        max(0, baseline.monthsToPayoff - accelerated.monthsToPayoff)
    }

    /// The future value of investing `extraMonthlyPayment` every month at `annualReturn`
    /// instead of paying it toward the mortgage. Compounded over the *baseline* payoff
    /// period (the loan's original, unaccelerated life): in the world where that money is
    /// invested rather than prepaid, the mortgage is never accelerated, so the minimum
    /// payment — and the freed-up extra dollars — keep going for the loan's full original term.
    func investedInstead(annualReturn: Double) -> Double {
        guard extraMonthlyPayment > 0, baseline.monthsToPayoff > 0 else { return 0 }
        let monthlyRate = annualReturn / 12
        let months = Double(baseline.monthsToPayoff)
        guard monthlyRate != 0 else { return extraMonthlyPayment * months }
        return extraMonthlyPayment * (pow(1 + monthlyRate, months) - 1) / monthlyRate
    }
}

enum MortgageAmortizationCalculator {
    /// 100 years. A schedule that has not paid off by here is treated as never paying off.
    private static let maxMonths = 1_200
    /// Assumed long-run real (inflation-adjusted) return for the "invested instead" comparison.
    static let opportunityCostRealReturn = 0.07

    static func amortization(for scenario: MortgageScenario) -> MortgageAmortization {
        guard scenario.principalBalance > 0 else {
            return MortgageAmortization(
                years: [],
                monthsToPayoff: 0,
                totalInterest: 0,
                scheduledPrincipal: 0,
                additionalPrincipal: 0,
                isPaidOff: true
            )
        }

        let monthlyRate = scenario.monthlyInterestRate
        var balance = scenario.principalBalance
        var totalInterest = 0.0
        var totalScheduledPrincipal = 0.0
        var totalAdditionalPrincipal = 0.0
        var rows: [MortgageAmortizationYear] = []
        var month = 0

        var yearIndex = 1
        var yearStartBalance = balance
        var yearInterest = 0.0
        var yearScheduledPrincipal = 0.0
        var yearAdditionalPrincipal = 0.0

        while balance > 0.005 && month < maxMonths {
            month += 1

            let interest = balance * monthlyRate
            // Never let the balance grow: floor scheduled principal at zero.
            var scheduledPrincipal = max(0, scenario.monthlyPrincipalInterest - interest)
            scheduledPrincipal = min(scheduledPrincipal, balance)

            let remainingAfterScheduled = balance - scheduledPrincipal
            let additional = min(scenario.additionalMonthlyPayment, remainingAfterScheduled)

            balance = remainingAfterScheduled - additional

            totalInterest += interest
            totalScheduledPrincipal += scheduledPrincipal
            totalAdditionalPrincipal += additional

            yearInterest += interest
            yearScheduledPrincipal += scheduledPrincipal
            yearAdditionalPrincipal += additional

            let isYearBoundary = month % 12 == 0
            let isPaidOff = balance <= 0.005
            if isYearBoundary || isPaidOff {
                rows.append(
                    MortgageAmortizationYear(
                        id: yearIndex,
                        year: yearIndex,
                        startingBalance: yearStartBalance,
                        principalPaid: yearScheduledPrincipal,
                        interestPaid: yearInterest,
                        additionalPaid: yearAdditionalPrincipal,
                        endingBalance: max(0, balance)
                    )
                )
                yearIndex += 1
                yearStartBalance = balance
                yearInterest = 0
                yearScheduledPrincipal = 0
                yearAdditionalPrincipal = 0
            }
        }

        let paidOff = balance <= 0.005
        return MortgageAmortization(
            years: paidOff ? rows : [],
            monthsToPayoff: paidOff ? month : 0,
            totalInterest: paidOff ? totalInterest : 0,
            scheduledPrincipal: paidOff ? totalScheduledPrincipal : 0,
            additionalPrincipal: paidOff ? totalAdditionalPrincipal : 0,
            isPaidOff: paidOff
        )
    }

    static func comparison(for scenario: MortgageScenario) -> MortgagePayoffComparison {
        var baselineScenario = scenario
        baselineScenario.additionalMonthlyPayment = 0

        return MortgagePayoffComparison(
            accelerated: amortization(for: scenario),
            baseline: amortization(for: baselineScenario),
            extraMonthlyPayment: scenario.additionalMonthlyPayment
        )
    }
}
