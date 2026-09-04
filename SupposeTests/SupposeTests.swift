import Foundation
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
        #expect(projection[0].previousBalance == 1_000)
        #expect(projection[0].yearOverYearChange == 1_200)
        #expect(projection[0].yearlyContributions == 1_200)
        #expect(projection[0].balance == 2_200)
        #expect(projection[1].previousBalance == 2_200)
        #expect(projection[1].yearOverYearChange == 1_200)
        #expect(projection[1].yearlyContributions == 1_200)
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
        #expect(projection[0].yearOverYearChange == projection[0].yearlyContributions + projection[0].interestEarned)
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

    @Test func mortgageInvestedInsteadMatchesAnnuityFutureValue() {
        let scenario = MortgageScenario(
            principalBalance: 300_000,
            annualInterestRate: 6,
            monthlyPrincipalInterest: 1_800,
            additionalMonthlyPayment: 200
        )
        let comparison = MortgageAmortizationCalculator.comparison(for: scenario)

        let monthlyRate = 0.07 / 12
        let months = Double(comparison.baseline.monthsToPayoff)
        let expected = 200 * (pow(1 + monthlyRate, months) - 1) / monthlyRate
        #expect(abs(comparison.investedInstead(annualReturn: 0.07) - expected) < 0.01)
        #expect(comparison.baseline.monthsToPayoff > comparison.accelerated.monthsToPayoff)
    }

    @Test func mortgageInvestedInsteadIsZeroWithNoAdditionalPayment() {
        let scenario = MortgageScenario(
            principalBalance: 300_000,
            annualInterestRate: 6,
            monthlyPrincipalInterest: 1_800,
            additionalMonthlyPayment: 0
        )
        let comparison = MortgageAmortizationCalculator.comparison(for: scenario)
        #expect(comparison.investedInstead(annualReturn: 0.07) == 0)
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

    @Test func mortgagePartialFinalYearIsIncluded() {
        let scenario = MortgageScenario(
            principalBalance: 25_000,
            annualInterestRate: 0,
            monthlyPrincipalInterest: 1_000,
            additionalMonthlyPayment: 0
        )

        let amortization = MortgageAmortizationCalculator.amortization(for: scenario)

        #expect(amortization.monthsToPayoff == 25)
        #expect(amortization.years.count == 3)
        #expect(amortization.years.last?.year == 3)
        #expect(amortization.years.last?.endingBalance == 0)
        #expect(amortization.years.last?.principalReduction == 1_000)
    }

    @Test func mortgageLargeAdditionalPaymentPaysOffWithoutOvershoot() {
        let scenario = MortgageScenario(
            principalBalance: 100_000,
            annualInterestRate: 5,
            monthlyPrincipalInterest: 600,
            additionalMonthlyPayment: 200_000
        )

        let amortization = MortgageAmortizationCalculator.amortization(for: scenario)

        #expect(amortization.isPaidOff)
        #expect(amortization.monthsToPayoff == 1)
        #expect(amortization.years.count == 1)
        #expect(abs(amortization.scheduledPrincipal + amortization.additionalPrincipal - 100_000) < 0.01)
        #expect(amortization.additionalPrincipal < 100_000)
    }

    @Test func mortgageComparisonHandlesBaselineThatNeverPaysOff() {
        let scenario = MortgageScenario(
            principalBalance: 300_000,
            annualInterestRate: 7,
            monthlyPrincipalInterest: 1_000,
            additionalMonthlyPayment: 2_000
        )

        let comparison = MortgageAmortizationCalculator.comparison(for: scenario)

        #expect(comparison.accelerated.isPaidOff)
        #expect(!comparison.baseline.isPaidOff)
        #expect(comparison.interestSaved == 0)
        #expect(comparison.monthsSaved == 0)
    }

    @Test func mortgageScenarioClampsNegativeInputs() {
        let scenario = MortgageScenario(
            principalBalance: -50_000,
            annualInterestRate: -3,
            monthlyPrincipalInterest: -100,
            additionalMonthlyPayment: -25
        )

        #expect(scenario.principalBalance == 0)
        #expect(scenario.annualInterestRate == 0)
        #expect(scenario.monthlyPrincipalInterest == 0)
        #expect(scenario.additionalMonthlyPayment == 0)
    }
}
