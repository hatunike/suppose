import Foundation

// 2026 figures — SEEDED VALUES, pending verification by the architect against
// IRS Notice 2025-67 (retirement plan limits) and Rev. Proc. 2025-19 (HSA/HDHP).
// Keep every dollar amount in this one block so corrections are a one-line change.
private enum Limits2026 {
    static let elective401k = 24_500.0
    static let catchUp401kAge50 = 8_000.0
    static let catchUp401kAge60to63 = 11_250.0
    static let iraBase = 7_500.0
    static let iraCatchUpAge50 = 1_100.0
    static let hsaSelfOnly = 4_400.0
    static let hsaFamily = 8_750.0
    static let hsaCatchUpAge55 = 1_000.0
    static let overallAdditions415c = 72_000.0

    static let rothIRA_MFJ = 242_000.0 ... 252_000.0
    static let rothIRA_single = 153_000.0 ... 168_000.0
    static let tradIRADeduction_MFJ_active = 129_000.0 ... 149_000.0
    static let tradIRADeduction_single_active = 81_000.0 ... 91_000.0
    static let tradIRADeduction_MFJ_spouseActive = 242_000.0 ... 252_000.0
}

enum AccountOwner: Equatable {
    case person(Int)
    case household
}

struct AccountRoom: Identifiable, Equatable {
    let id: String
    let name: String
    let owner: AccountOwner
    let limit: Double
    let preTax: Double
    let roth: Double
    let afterTax: Double
    let notes: [String]
}

struct ContributionRoomSummary: Equatable {
    let accounts: [AccountRoom]
    let totalRoom: Double
    let totalPreTax: Double
    let totalRoth: Double
    let totalAfterTax: Double
}

enum ContributionRoomCalculator {
    /// Reduces an IRA dollar limit across a MAGI phase-out range using the IRS method:
    /// the reduction is rounded up to the next $10, and a positive result below $200 is
    /// bumped to $200. At or below the range it is the full `base`; at or above it is $0.
    static func iraPhaseOutAllowed(base: Double, magi: Double, range: ClosedRange<Double>) -> Double {
        if magi <= range.lowerBound { return base }
        if magi >= range.upperBound { return 0 }
        let reduction = (base * (magi - range.lowerBound) / (range.upperBound - range.lowerBound) / 10).rounded(.up) * 10
        let allowed = max(0, base - reduction)
        return allowed > 0 && allowed < 200 ? 200 : allowed
    }

    static func summary(for scenario: ContributionRoomScenario) -> ContributionRoomSummary {
        let people = scenario.people
        let iraCaps = people.map { Limits2026.iraBase + ($0.age >= 50 ? Limits2026.iraCatchUpAge50 : 0) }
        let incomeCaps: [Double]
        if scenario.isMarried {
            let combined = scenario.personOne.earnedIncome + scenario.personTwo.earnedIncome
            let first = min(iraCaps[0], combined)
            incomeCaps = [first, min(iraCaps[1], max(0, combined - first))]
        } else {
            incomeCaps = [min(iraCaps[0], scenario.personOne.earnedIncome)]
        }

        var accounts: [AccountRoom] = []
        for (index, person) in people.enumerated() {
            var iraNotes: [String] = []
            if incomeCaps[index] < iraCaps[index] {
                iraNotes.append(scenario.isMarried ? "Limited by the household's combined earned income." : "Capped by earned income.")
            }

            switch person.iraChoice {
            case .roth:
                let range = scenario.isMarried ? Limits2026.rothIRA_MFJ : Limits2026.rothIRA_single
                let allowed = iraPhaseOutAllowed(base: incomeCaps[index], magi: scenario.householdMAGI, range: range)
                if allowed == 0 {
                    iraNotes.append("MAGI above the Roth IRA limit — consider a backdoor Roth via a nondeductible Traditional IRA.")
                } else if allowed < incomeCaps[index] {
                    iraNotes.append("Reduced by the Roth IRA MAGI phase-out.")
                }
                accounts.append(AccountRoom(id: "person-\(index)-ira", name: "Roth IRA", owner: .person(index), limit: allowed, preTax: 0, roth: allowed, afterTax: 0, notes: iraNotes))
            case .traditional:
                let contribution = incomeCaps[index]
                let deductionRange: ClosedRange<Double>?
                if person.hasWorkplacePlan {
                    deductionRange = scenario.isMarried ? Limits2026.tradIRADeduction_MFJ_active : Limits2026.tradIRADeduction_single_active
                } else if scenario.isMarried && people[1 - index].hasWorkplacePlan {
                    deductionRange = Limits2026.tradIRADeduction_MFJ_spouseActive
                } else {
                    deductionRange = nil
                }
                let deductible = min(contribution, max(0, deductionRange.map { iraPhaseOutAllowed(base: contribution, magi: scenario.householdMAGI, range: $0) } ?? contribution))
                let nondeductible = contribution - deductible
                if nondeductible == 0 {
                    iraNotes.append("Fully deductible.")
                } else if deductible > 0 {
                    iraNotes.append("Partially deductible (~\(currency(deductible)) of \(currency(contribution))).")
                } else if contribution > 0 {
                    iraNotes.append("Not deductible — a nondeductible (basis) contribution.")
                }
                accounts.append(AccountRoom(id: "person-\(index)-ira", name: "Traditional IRA", owner: .person(index), limit: contribution, preTax: deductible, roth: 0, afterTax: nondeductible, notes: iraNotes))
            }

            guard person.hasWorkplacePlan else { continue }
            let catchUp = (60...63).contains(person.age) ? Limits2026.catchUp401kAge60to63 : (person.age >= 50 ? Limits2026.catchUp401kAge50 : 0)
            let deferralLimit = Limits2026.elective401k + catchUp
            let deferralAllowed = min(deferralLimit, person.earnedIncome)
            let incomeCapNote = deferralAllowed < deferralLimit ? ["Capped by earned income."] : []
            let roth = deferralAllowed * person.roth401kPercent / 100
            accounts.append(AccountRoom(id: "person-\(index)-401k-deferral", name: "401(k) elective deferral", owner: .person(index), limit: deferralAllowed, preTax: deferralAllowed - roth, roth: roth, afterTax: 0, notes: incomeCapNote))

            if person.hasAfterTax401k {
                let additionsCeiling = min(Limits2026.overallAdditions415c + catchUp, person.earnedIncome)
                let afterTaxRoom = max(0, additionsCeiling - deferralAllowed - person.expectedEmployerContribution)
                var afterTaxNotes = ["Room toward the $72,000 total-additions limit; convertible to Roth (mega-backdoor)."]
                if additionsCeiling < Limits2026.overallAdditions415c + catchUp {
                    afterTaxNotes.append("Capped by earned income.")
                }
                accounts.append(AccountRoom(id: "person-\(index)-401k-after-tax", name: "401(k) after-tax", owner: .person(index), limit: afterTaxRoom, preTax: 0, roth: 0, afterTax: afterTaxRoom, notes: afterTaxNotes))
            }
        }

        if scenario.hsaCoverage != .none {
            let base = scenario.hsaCoverage == .family ? Limits2026.hsaFamily : Limits2026.hsaSelfOnly
            let catchUps: Double
            if scenario.hsaCoverage == .selfOnly {
                catchUps = scenario.personOne.age >= 55 ? Limits2026.hsaCatchUpAge55 : 0
            } else {
                catchUps = Double(people.filter { $0.age >= 55 }.count) * Limits2026.hsaCatchUpAge55
            }
            let total = base + catchUps
            let note = scenario.hsaCoverage == .family && scenario.isMarried
                ? "Assumes both spouses hold an HSA; each 55+ catch-up must go in that spouse's own account."
                : "Assumes Person 1 holds the HSA."
            accounts.append(AccountRoom(id: "household-hsa", name: "HSA", owner: .household, limit: total, preTax: total, roth: 0, afterTax: 0, notes: [note]))
        }

        return ContributionRoomSummary(
            accounts: accounts,
            totalRoom: accounts.reduce(0) { $0 + $1.limit },
            totalPreTax: accounts.reduce(0) { $0 + $1.preTax },
            totalRoth: accounts.reduce(0) { $0 + $1.roth },
            totalAfterTax: accounts.reduce(0) { $0 + $1.afterTax }
        )
    }

    private static func currency(_ value: Double) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
    }
}
