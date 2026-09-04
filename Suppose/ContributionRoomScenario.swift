import Foundation

enum FilingStatus: String, CaseIterable, Identifiable, Equatable {
    case single
    case marriedFilingJointly
    var id: String { rawValue }
}

enum HSACoverage: String, CaseIterable, Identifiable, Equatable {
    case none
    case selfOnly
    case family
    var id: String { rawValue }
}

enum IRAChoice: String, CaseIterable, Identifiable, Equatable {
    case roth
    case traditional
    var id: String { rawValue }
}

struct PersonInput: Equatable {
    var age: Int
    var earnedIncome: Double
    var hasWorkplacePlan: Bool
    var expectedEmployerContribution: Double
    var roth401kPercent: Double
    var iraChoice: IRAChoice
    var hasAfterTax401k: Bool

    init(age: Int, earnedIncome: Double, hasWorkplacePlan: Bool,
         expectedEmployerContribution: Double, roth401kPercent: Double, iraChoice: IRAChoice,
         hasAfterTax401k: Bool) {
        self.age = min(120, max(0, age))
        self.earnedIncome = max(0, earnedIncome)
        self.hasWorkplacePlan = hasWorkplacePlan
        self.expectedEmployerContribution = max(0, expectedEmployerContribution)
        self.roth401kPercent = min(100, max(0, roth401kPercent))
        self.iraChoice = iraChoice
        self.hasAfterTax401k = hasAfterTax401k
    }
}

struct ContributionRoomScenario: Equatable {
    var filingStatus: FilingStatus
    var personOne: PersonInput
    var personTwo: PersonInput
    var householdMAGI: Double
    var hsaCoverage: HSACoverage

    init(filingStatus: FilingStatus, personOne: PersonInput, personTwo: PersonInput,
         householdMAGI: Double, hsaCoverage: HSACoverage) {
        self.filingStatus = filingStatus
        self.personOne = personOne
        self.personTwo = personTwo
        self.householdMAGI = max(0, householdMAGI)
        self.hsaCoverage = hsaCoverage
    }

    /// The people whose accounts are modeled: one when single, two when MFJ.
    var people: [PersonInput] {
        filingStatus == .single ? [personOne] : [personOne, personTwo]
    }

    var isMarried: Bool { filingStatus == .marriedFilingJointly }
}
