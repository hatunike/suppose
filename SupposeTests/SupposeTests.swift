import Testing
@testable import Suppose

struct SupposeTests {
    @Test func zeroInterestAddsMonthlyContributions() {
        let scenario = InvestmentScenario(
            startingValue: 1_000,
            monthlyContribution: 100,
            annualInterestRate: 0,
            currentAge: 40,
            projectionYears: 2
        )

        let projection = InvestmentProjectionCalculator.projection(for: scenario)

        #expect(projection.count == 2)
        #expect(projection[0].age == 41)
        #expect(projection[0].balance == 2_200)
        #expect(projection[1].balance == 3_400)
        #expect(projection[1].contributed == 3_400)
    }

    @Test func monthlyCompoundingIncreasesBalance() {
        let scenario = InvestmentScenario(
            startingValue: 10_000,
            monthlyContribution: 500,
            annualInterestRate: 6,
            currentAge: 35,
            projectionYears: 1
        )

        let projection = InvestmentProjectionCalculator.projection(for: scenario)

        #expect(projection[0].balance > 16_000)
        #expect(projection[0].interestEarned > 0)
    }

    @Test func negativeReturnAssumptionCanReduceBalance() {
        let scenario = InvestmentScenario(
            startingValue: 10_000,
            monthlyContribution: 0,
            annualInterestRate: -12,
            currentAge: 35,
            projectionYears: 1
        )

        let projection = InvestmentProjectionCalculator.projection(for: scenario)

        #expect(projection[0].balance < 10_000)
        #expect(projection[0].interestEarned < 0)
    }
}
