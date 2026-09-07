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

    private func contributionScenario(
        filingStatus: FilingStatus = .marriedFilingJointly,
        ageOne: Int = 40,
        ageTwo: Int = 38,
        incomeOne: Double = 200_000,
        incomeTwo: Double = 100_000,
        planOne: Bool = true,
        planTwo: Bool = false,
        employerOne: Double = 0,
        rothPercentOne: Double = 0,
        iraOne: IRAChoice = .roth,
        iraTwo: IRAChoice = .roth,
        magi: Double = 100_000,
        hsa: HSACoverage = .none,
        afterTaxOne: Bool = true,
        afterTaxTwo: Bool = true
    ) -> ContributionRoomScenario {
        ContributionRoomScenario(
            filingStatus: filingStatus,
            personOne: PersonInput(age: ageOne, earnedIncome: incomeOne, hasWorkplacePlan: planOne, expectedEmployerContribution: employerOne, roth401kPercent: rothPercentOne, iraChoice: iraOne, hasAfterTax401k: afterTaxOne),
            personTwo: PersonInput(age: ageTwo, earnedIncome: incomeTwo, hasWorkplacePlan: planTwo, expectedEmployerContribution: 0, roth401kPercent: 0, iraChoice: iraTwo, hasAfterTax401k: afterTaxTwo),
            householdMAGI: magi,
            hsaCoverage: hsa
        )
    }

    private func account(_ name: String, owner: AccountOwner = .person(0), in scenario: ContributionRoomScenario) -> AccountRoom {
        ContributionRoomCalculator.summary(for: scenario).accounts.first { $0.name == name && $0.owner == owner }!
    }

    @Test func contributionRoomAge50CatchUps() {
        let scenario = contributionScenario(ageOne: 52)
        #expect(account("401(k) elective deferral", in: scenario).limit == 24_500 + 8_000)
        #expect(account("Roth IRA", in: scenario).limit == 8_600)
    }

    @Test func contributionRoomAge60to63SuperCatchUp() {
        #expect(account("401(k) elective deferral", in: contributionScenario(ageOne: 61)).limit == 35_750)
        #expect(account("401(k) elective deferral", in: contributionScenario(ageOne: 64)).limit == 32_500)
    }

    @Test func contributionRoomAge49NoCatchUp() {
        let scenario = contributionScenario(ageOne: 49)
        #expect(account("401(k) elective deferral", in: scenario).limit == 24_500)
        #expect(account("Roth IRA", in: scenario).limit == 7_500)
    }

    @Test func contributionRoomHSAFamilyVsSelfOnly() {
        #expect(account("HSA", owner: .household, in: contributionScenario(planOne: false, hsa: .family)).limit == 8_750)
        #expect(account("HSA", owner: .household, in: contributionScenario(planOne: false, hsa: .selfOnly)).limit == 4_400)
        #expect(account("HSA", owner: .household, in: contributionScenario(ageOne: 56, ageTwo: 56, planOne: false, hsa: .family)).limit == 10_750)
    }

    @Test func contributionRoom401kDeferralCappedByEarnedIncome() {
        let result = account("401(k) elective deferral", in: contributionScenario(incomeOne: 10_000))
        #expect(result.limit == 10_000)
        #expect(result.notes.contains("Capped by earned income."))
    }

    @Test func contributionRoomAfterTaxRoom() {
        let result = account("401(k) after-tax", in: contributionScenario(employerOne: 20_000))
        #expect(result.limit == 27_500)
    }

    @Test func contributionRoomAfterTaxOmittedWhenToggledOff() {
        let scenario = contributionScenario(employerOne: 20_000, afterTaxOne: false)
        #expect(!ContributionRoomCalculator.summary(for: scenario).accounts.contains { $0.name == "401(k) after-tax" })
    }

    @Test func contributionRoomRothIRAZeroAbovePhaseOut() {
        let result = account("Roth IRA", in: contributionScenario(magi: 300_000))
        #expect(result.limit == 0)
        #expect(result.notes.contains { $0.localizedCaseInsensitiveContains("backdoor") })
    }

    @Test func contributionRoomRothIRAPartialInPhaseOut() {
        let result = account("Roth IRA", in: contributionScenario(magi: 247_000))
        #expect(result.limit > 0 && result.limit < 7_500)
        #expect(result.limit == 200 || result.limit.truncatingRemainder(dividingBy: 10) == 0)
    }

    @Test func contributionRoomTraditionalNotDeductibleWhenCoveredHighMAGI() {
        let result = account("Traditional IRA", in: contributionScenario(iraOne: .traditional, magi: 200_000))
        #expect(result.limit == 7_500)
        #expect(result.preTax == 0)
        #expect(result.afterTax == 7_500)
        #expect(result.notes.contains { $0.localizedCaseInsensitiveContains("not deductible") })
    }

    @Test func contributionRoomTraditionalDeductibleWhenNoPlan() {
        let result = account("Traditional IRA", in: contributionScenario(filingStatus: .single, planOne: false, iraOne: .traditional, magi: 200_000))
        #expect(result.preTax == 7_500)
        #expect(result.afterTax == 0)
    }

    @Test func contributionRoomSpousalIRAUsesCombinedEarnedIncome() {
        let scenario = contributionScenario(incomeOne: 200_000, incomeTwo: 0)
        #expect(account("Roth IRA", owner: .person(1), in: scenario).limit == 7_500)
    }

    @Test func contributionRoomSingleIRACappedByOwnIncome() {
        let scenario = contributionScenario(filingStatus: .single, incomeOne: 3_000, planOne: false)
        #expect(account("Roth IRA", in: scenario).limit == 3_000)
    }

    @Test func contributionRoomTotalsAreConsistent() {
        let summary = ContributionRoomCalculator.summary(for: contributionScenario(ageOne: 55, planTwo: true, employerOne: 5_000, rothPercentOne: 40, iraTwo: .traditional, magi: 140_000, hsa: .family))
        #expect(summary.totalRoom == summary.totalPreTax + summary.totalRoth + summary.totalAfterTax)
        #expect(summary.totalRoom == summary.accounts.map(\.limit).reduce(0, +))
    }

    @Test func contributionRoomSingleFilingIgnoresPersonTwo() {
        var scenario = contributionScenario(filingStatus: .single)
        let original = ContributionRoomCalculator.summary(for: scenario)
        #expect(!original.accounts.contains { $0.owner == .person(1) })
        scenario.personTwo = PersonInput(age: 99, earnedIncome: 1, hasWorkplacePlan: true, expectedEmployerContribution: 999_999, roth401kPercent: 100, iraChoice: .traditional, hasAfterTax401k: true)
        #expect(ContributionRoomCalculator.summary(for: scenario) == original)
    }

    @Test func contributionRoomScenarioClampsNegativeInputs() {
        let high = PersonInput(age: -5, earnedIncome: -1, hasWorkplacePlan: true, expectedEmployerContribution: -2, roth401kPercent: 150, iraChoice: .roth, hasAfterTax401k: true)
        let low = PersonInput(age: 150, earnedIncome: -1, hasWorkplacePlan: false, expectedEmployerContribution: -2, roth401kPercent: -20, iraChoice: .traditional, hasAfterTax401k: false)
        let scenario = ContributionRoomScenario(filingStatus: .marriedFilingJointly, personOne: high, personTwo: low, householdMAGI: -3, hsaCoverage: .none)
        #expect(scenario.personOne.age == 0)
        #expect(scenario.personTwo.age == 120)
        #expect(scenario.personOne.earnedIncome == 0 && scenario.personOne.expectedEmployerContribution == 0)
        #expect(scenario.personOne.roth401kPercent == 100 && scenario.personTwo.roth401kPercent == 0)
        #expect(scenario.householdMAGI == 0)
    }

    @Test func withdrawalRateNetWorthRowsAreFlatHundredThousandSteps() {
        let netWorths = WithdrawalRateGrid.netWorths
        #expect(netWorths.first == 300_000)
        #expect(netWorths.last == 10_000_000)
        for index in 1..<netWorths.count {
            #expect(netWorths[index] - netWorths[index - 1] == 100_000)
        }
    }

    @Test func withdrawalRateAnnualWithdrawalScalesWithNetWorthAndRate() {
        #expect(WithdrawalRateGrid.annualWithdrawal(netWorth: 1_000_000, ratePercent: 4.0) == 40_000)
        #expect(WithdrawalRateGrid.annualWithdrawal(netWorth: 2_500_000, ratePercent: 3.25) == 81_250)
    }

    @Test func withdrawalRateFailureRateIncreasesWithRate() {
        let low = PortfolioAllocation.sixtyForty.failureRatePercent(forWithdrawalRate: 3.25)
        let high = PortfolioAllocation.sixtyForty.failureRatePercent(forWithdrawalRate: 5.00)
        #expect(low < high)
    }

    @Test func withdrawalRateFailureRateLooksUpEachAllocation() {
        for allocation in PortfolioAllocation.allCases {
            for rate in WithdrawalRateGrid.withdrawalRates {
                let failureRate = allocation.failureRatePercent(forWithdrawalRate: rate)
                #expect(failureRate >= 0 && failureRate <= 100)
            }
        }
    }

    @Test func withdrawalRateAllocationTogglesThroughAllCases() {
        var allocation = PortfolioAllocation.sixtyForty
        allocation.toggle()
        #expect(allocation == .seventyFiveTwentyFive)
        allocation.toggle()
        #expect(allocation == .allStock)
        allocation.toggle()
        #expect(allocation == .sixtyForty)
    }

    @Test func withdrawalRateChanceAtRanOutMatchesFailureRate() {
        for allocation in PortfolioAllocation.allCases {
            for rate in WithdrawalRateGrid.withdrawalRates {
                let failure = allocation.failureRatePercent(forWithdrawalRate: rate)
                let chance = allocation.chanceEndingBalance(atOrBelow: .ranOut, forWithdrawalRate: rate)
                #expect(failure == chance)
            }
        }
    }

    @Test func withdrawalRateChanceIncreasesWithHigherThreshold() {
        let allocation = PortfolioAllocation.sixtyForty
        var previous = -1
        for threshold in BalanceThreshold.allCases {
            let chance = allocation.chanceEndingBalance(atOrBelow: threshold, forWithdrawalRate: 4.0)
            #expect(chance >= previous)
            #expect(chance >= 0 && chance <= 100)
            previous = chance
        }
    }

    @Test func withdrawalRateChanceIncreasesWithHigherWithdrawalRate() {
        let low = PortfolioAllocation.sixtyForty.chanceEndingBalance(atOrBelow: .oneHundred, forWithdrawalRate: 3.25)
        let high = PortfolioAllocation.sixtyForty.chanceEndingBalance(atOrBelow: .oneHundred, forWithdrawalRate: 5.00)
        #expect(high > low)
    }

    @Test func withdrawalRateAtOrAboveIsComplementOfAtOrBelow() {
        for allocation in PortfolioAllocation.allCases {
            for threshold in BalanceThreshold.allCases {
                let below = allocation.chanceEndingBalance(.atOrBelow, threshold: threshold, forWithdrawalRate: 4.0)
                let above = allocation.chanceEndingBalance(.atOrAbove, threshold: threshold, forWithdrawalRate: 4.0)
                #expect(below + above == 100)
            }
        }
    }

    @Test func withdrawalRateComparisonDirectionToggles() {
        var direction = ComparisonDirection.atOrBelow
        direction.toggle()
        #expect(direction == .atOrAbove)
        direction.toggle()
        #expect(direction == .atOrBelow)
    }

    @Test func historicalMarketReturnsCoverEveryYearInRange() {
        let years = HistoricalMarketReturns.years
        #expect(years.first?.year == 1928)
        #expect(years.last?.year == 2025)
        for index in 1..<years.count {
            #expect(years[index].year == years[index - 1].year + 1)
        }
    }

    @Test func historicalMarketReturnRealReturnUsesFisherEquation() {
        let year = HistoricalMarketYear(year: 2000, nominalReturnPercent: 10, inflationRatePercent: 4)
        let expected = ((1.10 / 1.04) - 1) * 100
        #expect(abs(year.realReturnPercent - expected) < 0.0001)
    }

    @Test func historicalMarketReturnRealReturnIsZeroWhenNominalMatchesInflation() {
        let year = HistoricalMarketYear(year: 2000, nominalReturnPercent: 5, inflationRatePercent: 5)
        #expect(abs(year.realReturnPercent) < 0.0001)
    }
}
