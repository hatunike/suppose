import Foundation

struct InvestmentProjectionYear: Identifiable, Equatable {
    let id: Int
    let year: Int
    let age: Int
    let previousBalance: Double
    let yearOverYearChange: Double
    let yearlyContributions: Double
    let contributed: Double
    let interestEarned: Double
    let balance: Double
}

enum InvestmentProjectionCalculator {
    static func projection(for scenario: InvestmentScenario) -> [InvestmentProjectionYear] {
        let monthlyRate = scenario.annualInterestRate / 100 / 12
        var balance = scenario.startingValue
        var totalContributed = scenario.startingValue
        var rows: [InvestmentProjectionYear] = []

        for year in 1...scenario.projectionYears {
            let startingBalance = balance

            for _ in 1...12 {
                balance += scenario.monthlyContribution
                totalContributed += scenario.monthlyContribution
                balance += balance * monthlyRate
            }

            let yearlyContributions = scenario.monthlyContribution * 12
            let interestEarned = balance - startingBalance - yearlyContributions

            rows.append(
                InvestmentProjectionYear(
                    id: year,
                    year: year,
                    age: scenario.currentAge + year,
                    previousBalance: startingBalance,
                    yearOverYearChange: balance - startingBalance,
                    yearlyContributions: yearlyContributions,
                    contributed: totalContributed,
                    interestEarned: interestEarned,
                    balance: balance
                )
            )
        }

        return rows
    }
}
