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

    @Test func mortgagePrincipalPaymentsSumToStartingBalance() {
        let scenario = MortgageScenario(
            principalBalance: 200_000,
            annualInterestRate: 6,
            monthlyPrincipalInterest: 1_500,
            additionalMonthlyPayment: 0
        )

        let amortization = MortgageAmortizationCalculator.amortization(for: scenario)

        #expect(amortization.isPaidOff)
        #expect(amortization.years.last?.endingBalance == 0)
        #expect(abs(amortization.scheduledPrincipal + amortization.additionalPrincipal - 200_000) < 0.01)
        #expect(amortization.monthsToPayoff > 12)
    }

    @Test func mortgageZeroInterestSplitsBalanceAcrossPayments() {
        let scenario = MortgageScenario(
            principalBalance: 12_000,
            annualInterestRate: 0,
            monthlyPrincipalInterest: 1_000,
            additionalMonthlyPayment: 0
        )

        let amortization = MortgageAmortizationCalculator.amortization(for: scenario)

        #expect(amortization.monthsToPayoff == 12)
        #expect(amortization.totalInterest == 0)
        #expect(amortization.years.count == 1)
        #expect(amortization.years[0].endingBalance == 0)
    }

    @Test func mortgageAdditionalPaymentSavesTimeAndInterest() {
        let scenario = MortgageScenario(
            principalBalance: 250_000,
            annualInterestRate: 5.5,
            monthlyPrincipalInterest: 1_600,
            additionalMonthlyPayment: 300
        )

        let comparison = MortgageAmortizationCalculator.comparison(for: scenario)

        #expect(comparison.accelerated.isPaidOff)
        #expect(comparison.baseline.isPaidOff)
        #expect(comparison.accelerated.monthsToPayoff < comparison.baseline.monthsToPayoff)
        #expect(comparison.interestSaved > 0)
        #expect(comparison.monthsSaved > 0)
    }

    @Test func mortgagePaymentBelowInterestNeverPaysOff() {
        let scenario = MortgageScenario(
            principalBalance: 300_000,
            annualInterestRate: 7,
            monthlyPrincipalInterest: 1_000,
            additionalMonthlyPayment: 0
        )

        let amortization = MortgageAmortizationCalculator.amortization(for: scenario)

        #expect(!amortization.isPaidOff)
        #expect(amortization.years.isEmpty)
        #expect(amortization.monthsToPayoff == 0)
    }
}
