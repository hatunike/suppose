import SwiftUI

struct ContributionRoomCalculatorView: View {
    @AppStorage("contributionRoom.filingStatus") private var filingStatus = "marriedFilingJointly"
    @AppStorage("contributionRoom.householdMAGI") private var householdMAGI = 200_000.0
    @AppStorage("contributionRoom.hsaCoverage") private var hsaCoverage = "family"
    @AppStorage("contributionRoom.p1.age") private var p1Age = 40
    @AppStorage("contributionRoom.p1.earnedIncome") private var p1EarnedIncome = 120_000.0
    @AppStorage("contributionRoom.p1.hasWorkplacePlan") private var p1HasWorkplacePlan = true
    @AppStorage("contributionRoom.p1.employerContribution") private var p1EmployerContribution = 6_000.0
    @AppStorage("contributionRoom.p1.roth401kPercent") private var p1Roth401kPercent = 0.0
    @AppStorage("contributionRoom.p1.iraChoice") private var p1IRAChoice = "roth"
    @AppStorage("contributionRoom.p1.hasAfterTax401k") private var p1HasAfterTax401k = false
    @AppStorage("contributionRoom.p2.age") private var p2Age = 38
    @AppStorage("contributionRoom.p2.earnedIncome") private var p2EarnedIncome = 90_000.0
    @AppStorage("contributionRoom.p2.hasWorkplacePlan") private var p2HasWorkplacePlan = true
    @AppStorage("contributionRoom.p2.employerContribution") private var p2EmployerContribution = 4_500.0
    @AppStorage("contributionRoom.p2.roth401kPercent") private var p2Roth401kPercent = 0.0
    @AppStorage("contributionRoom.p2.iraChoice") private var p2IRAChoice = "roth"
    @AppStorage("contributionRoom.p2.hasAfterTax401k") private var p2HasAfterTax401k = false
    @FocusState private var focusedInput: ContributionRoomInput?

    private var selectedFilingStatus: FilingStatus {
        FilingStatus(rawValue: filingStatus) ?? .marriedFilingJointly
    }

    private var scenario: ContributionRoomScenario {
        ContributionRoomScenario(
            filingStatus: selectedFilingStatus,
            personOne: PersonInput(age: p1Age, earnedIncome: p1EarnedIncome, hasWorkplacePlan: p1HasWorkplacePlan, expectedEmployerContribution: p1EmployerContribution, roth401kPercent: p1Roth401kPercent, iraChoice: IRAChoice(rawValue: p1IRAChoice) ?? .roth, hasAfterTax401k: p1HasAfterTax401k),
            personTwo: PersonInput(age: p2Age, earnedIncome: p2EarnedIncome, hasWorkplacePlan: p2HasWorkplacePlan, expectedEmployerContribution: p2EmployerContribution, roth401kPercent: p2Roth401kPercent, iraChoice: IRAChoice(rawValue: p2IRAChoice) ?? .roth, hasAfterTax401k: p2HasAfterTax401k),
            householdMAGI: householdMAGI,
            hsaCoverage: HSACoverage(rawValue: hsaCoverage) ?? .family
        )
    }

    private var summary: ContributionRoomSummary {
        ContributionRoomCalculator.summary(for: scenario)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                inputs
                summaryCard
                breakdown
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Contribution Room")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedInput = nil }
            }
        }
    }

    private var inputs: some View {
        VStack(spacing: 10) {
            Picker("Filing", selection: $filingStatus) {
                Text("Single").tag(FilingStatus.single.rawValue)
                Text("Married (joint)").tag(FilingStatus.marriedFilingJointly.rawValue)
            }
            .pickerStyle(.segmented)
            currencyField("Household MAGI", value: $householdMAGI, input: .householdMAGI)
            Picker("HSA coverage", selection: $hsaCoverage) {
                Text("None").tag(HSACoverage.none.rawValue)
                Text("Self-only").tag(HSACoverage.selfOnly.rawValue)
                Text("Family").tag(HSACoverage.family.rawValue)
            }
            .pickerStyle(.segmented)

            personSection(title: "Person 1", age: $p1Age, earnedIncome: $p1EarnedIncome, hasWorkplacePlan: $p1HasWorkplacePlan, employerContribution: $p1EmployerContribution, roth401kPercent: $p1Roth401kPercent, iraChoice: $p1IRAChoice, hasAfterTax401k: $p1HasAfterTax401k, earnedInput: .p1EarnedIncome, employerInput: .p1Employer)
            if selectedFilingStatus == .marriedFilingJointly {
                Divider()
                personSection(title: "Person 2", age: $p2Age, earnedIncome: $p2EarnedIncome, hasWorkplacePlan: $p2HasWorkplacePlan, employerContribution: $p2EmployerContribution, roth401kPercent: $p2Roth401kPercent, iraChoice: $p2IRAChoice, hasAfterTax401k: $p2HasAfterTax401k, earnedInput: .p2EarnedIncome, employerInput: .p2Employer)
            }
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func personSection(title: String, age: Binding<Int>, earnedIncome: Binding<Double>, hasWorkplacePlan: Binding<Bool>, employerContribution: Binding<Double>, roth401kPercent: Binding<Double>, iraChoice: Binding<String>, hasAfterTax401k: Binding<Bool>, earnedInput: ContributionRoomInput, employerInput: ContributionRoomInput) -> some View {
        VStack(spacing: 10) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text("Age").font(.subheadline.weight(.semibold))
                Spacer()
                Stepper(value: age, in: 0...120) { Text(age.wrappedValue.formatted()).font(.headline.monospacedDigit()) }
            }
            currencyField("Earned income", value: earnedIncome, input: earnedInput)
            Toggle("Workplace 401(k)/403(b)", isOn: hasWorkplacePlan).font(.subheadline.weight(.semibold))
            currencyField("Employer contribution", value: employerContribution, input: employerInput)
                .disabled(!hasWorkplacePlan.wrappedValue)
                .opacity(hasWorkplacePlan.wrappedValue ? 1 : 0.45)
            HStack {
                Text("Roth 401(k)").font(.subheadline.weight(.semibold))
                Spacer()
                Stepper(value: roth401kPercent, in: 0...100, step: 5) { Text("\(Int(roth401kPercent.wrappedValue))%").font(.headline.monospacedDigit()) }
            }
            Picker("IRA", selection: iraChoice) {
                Text("Roth").tag(IRAChoice.roth.rawValue)
                Text("Traditional").tag(IRAChoice.traditional.rawValue)
            }
            .pickerStyle(.segmented)
            Toggle("Plan allows after-tax 401(k)", isOn: hasAfterTax401k)
                .font(.subheadline.weight(.semibold))
                .disabled(!hasWorkplacePlan.wrappedValue)
                .opacity(hasWorkplacePlan.wrappedValue ? 1 : 0.45)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            metric("Total room", text: currency(summary.totalRoom))
            HStack(spacing: 12) {
                metric("Pre-tax", text: currency(summary.totalPreTax))
                metric("Roth", text: currency(summary.totalRoth))
                metric("After-tax", text: currency(summary.totalAfterTax))
            }
        }
        .padding(16)
        .background(LinearGradient(colors: [Color.teal.opacity(0.18), Color.indigo.opacity(0.14)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts").font(.headline)
                Spacer()
                Text("Pre-tax · Roth · After-tax").font(.caption.weight(.medium)).foregroundStyle(.secondary)
            }
            LazyVStack(spacing: 8) {
                ForEach(summary.accounts) { account in
                    AccountRoomRow(account: account, ownerLabel: ownerLabel(account.owner))
                }
            }
        }
    }

    private func ownerLabel(_ owner: AccountOwner) -> String {
        switch owner {
        case .person(let index): "Person \(index + 1)"
        case .household: "Household"
        }
    }

    private func metric(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            Text(text).font(.title3.weight(.bold).monospacedDigit()).minimumScaleFactor(0.72).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func currencyField(_ title: String, value: Binding<Double>, input: ContributionRoomInput) -> some View {
        LabeledContent {
            TextField(title, value: value, format: .currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
                .keyboardType(.numberPad).multilineTextAlignment(.trailing).font(.headline.monospacedDigit()).focused($focusedInput, equals: input)
        } label: { Text(title).font(.subheadline.weight(.semibold)) }
    }
}

private enum ContributionRoomInput: Hashable {
    case householdMAGI, p1EarnedIncome, p1Employer, p2EarnedIncome, p2Employer
}

private struct AccountRoomRow: View {
    let account: AccountRoom
    let ownerLabel: String

    private var buckets: String {
        [("Pre-tax", account.preTax), ("Roth", account.roth), ("After-tax", account.afterTax)]
            .filter { $0.1 != 0 }
            .map { "\($0.0) \(currency($0.1))" }
            .joined(separator: " · ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(account.name).font(.subheadline.weight(.semibold))
                Text(ownerLabel).font(.caption).foregroundStyle(.secondary)
            }
            .frame(width: 92, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(currency(account.limit)).font(.headline.monospacedDigit())
                if !buckets.isEmpty { Text(buckets).font(.caption2).lineLimit(1) }
                ForEach(account.notes, id: \.self) { note in
                    Text(note).font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14).background(.background).clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private func currency(_ value: Double) -> String {
    value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
}

#Preview { NavigationStack { ContributionRoomCalculatorView() } }
