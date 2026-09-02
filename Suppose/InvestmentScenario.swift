import Foundation

struct InvestmentScenario: Equatable {
    var startingValue: Double
    var monthlyContribution: Double
    var annualInterestRate: Double
    var currentAge: Int
    var projectionYears: Int

    init(
        startingValue: Double,
        monthlyContribution: Double,
        annualInterestRate: Double,
        currentAge: Int,
        projectionYears: Int = 40
    ) {
        self.startingValue = max(0, startingValue)
        self.monthlyContribution = max(0, monthlyContribution)
        self.annualInterestRate = max(-100, annualInterestRate)
        self.currentAge = max(0, currentAge)
        self.projectionYears = max(1, projectionYears)
    }
}
