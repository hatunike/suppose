import SwiftUI

struct InvestmentCalculatorView: View {
    // Inputs are stored in UserDefaults so they survive navigation and app relaunches;
    // each field keeps whatever the user last entered.
    @AppStorage("investment.startingValue") private var startingValue = 10000.0
    @AppStorage("investment.monthlyContribution") private var monthlyContribution = 500.0
    @AppStorage("investment.annualInterestRate") private var annualInterestRate = 7.0
    @AppStorage("investment.currentAge") private var currentAge = 35
    @State private var rowComparisonMode = RowComparisonMode.yearDelta
    @FocusState private var focusedInput: InvestmentInput?

    private var scenario: InvestmentScenario {
        InvestmentScenario(
            startingValue: startingValue,
            monthlyContribution: monthlyContribution,
            annualInterestRate: annualInterestRate,
            currentAge: currentAge
        )
    }

    private var projection: [InvestmentProjectionYear] {
        InvestmentProjectionCalculator.projection(for: scenario)
    }

    private var finalBalance: Double {
        projection.last?.balance ?? startingValue
    }

    private var totalContributed: Double {
        projection.last?.contributed ?? startingValue
    }

    private var totalGrowth: Double {
        finalBalance - totalContributed
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                inputs
                summary
                projectionList
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Investment")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedInput = nil
                }
            }
        }
    }

    private var inputs: some View {
        VStack(spacing: 10) {
            currencyField("Starting", value: $startingValue, input: .startingValue)
            currencyField("Monthly", value: $monthlyContribution, input: .monthlyContribution)
            percentField("Interest", value: $annualInterestRate)
            ageStepper
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                metric("Final balance", value: finalBalance, style: .currency)
                metric("Contributed", value: totalContributed, style: .currency)
            }

            metric("Estimated growth", value: totalGrowth, style: .currency)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.teal.opacity(0.18), Color.indigo.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var projectionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Annual balances")
                    .font(.headline)
                Spacer()
                Button {
                    rowComparisonMode.toggle()
                } label: {
                    Text(rowComparisonMode.title)
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            LazyVStack(spacing: 8) {
                ForEach(projection) { row in
                    ProjectionRow(
                        row: row,
                        finalBalance: finalBalance,
                        comparisonMode: rowComparisonMode
                    )
                    .onTapGesture {
                        rowComparisonMode.toggle()
                    }
                }
            }
        }
    }

    private var ageStepper: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Age")
                    .font(.subheadline.weight(.semibold))
            }
            Spacer()
            Stepper(value: $currentAge, in: 0...120) {
                Text(currentAge, format: .number)
                    .font(.headline.monospacedDigit())
                    .frame(minWidth: 40, alignment: .trailing)
            }
            .fixedSize()
        }
    }

    private func currencyField(_ title: String, value: Binding<Double>, input: InvestmentInput) -> some View {
        LabeledContent {
            TextField(title, value: value, format: .currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.headline.monospacedDigit())
                .focused($focusedInput, equals: input)
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func percentField(_ title: String, value: Binding<Double>) -> some View {
        LabeledContent {
            HStack(spacing: 4) {
                TextField(title, value: value, format: .number.precision(.fractionLength(0...2)))
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
                    .font(.headline.monospacedDigit())
                    .focused($focusedInput, equals: .annualInterestRate)
                Text("%")
                    .foregroundStyle(.secondary)
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func metric(_ title: String, value: Double, style: MetricStyle) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(formatted(value, style: style))
                .font(.title3.weight(.bold).monospacedDigit())
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatted(_ value: Double, style: MetricStyle) -> String {
        switch style {
        case .currency:
            value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
        }
    }
}

private enum InvestmentInput: Hashable {
    case startingValue
    case monthlyContribution
    case annualInterestRate
}

private enum MetricStyle {
    case currency
}

private enum RowComparisonMode {
    case yearDelta
    case previousBalance
    case totalContributions
    case yearlyContributions
    case investmentGrowth

    var title: String {
        switch self {
        case .yearDelta:
            "Annual change"
        case .previousBalance:
            "Prior balance"
        case .totalContributions:
            "Total contributed"
        case .yearlyContributions:
            "Year contributed"
        case .investmentGrowth:
            "Growth"
        }
    }

    var rowLabel: String {
        switch self {
        case .yearDelta:
            "Change"
        case .previousBalance:
            "Prior"
        case .totalContributions:
            "Total in"
        case .yearlyContributions:
            "Year in"
        case .investmentGrowth:
            "Growth"
        }
    }

    mutating func toggle() {
        switch self {
        case .yearDelta:
            self = .previousBalance
        case .previousBalance:
            self = .totalContributions
        case .totalContributions:
            self = .yearlyContributions
        case .yearlyContributions:
            self = .investmentGrowth
        case .investmentGrowth:
            self = .yearDelta
        }
    }
}

private struct ProjectionRow: View {
    let row: InvestmentProjectionYear
    let finalBalance: Double
    let comparisonMode: RowComparisonMode

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Year \(row.year)")
                    .font(.subheadline.weight(.semibold))
                Text("Age \(row.age)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 76, alignment: .leading)

            VStack(alignment: .leading, spacing: 5) {
                Text(row.balance.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0))))
                    .font(.headline.monospacedDigit())
                ProgressView(value: row.balance, total: max(finalBalance, 1))
                    .tint(.teal)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text(comparisonValue)
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(comparisonColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(comparisonMode.rowLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 92, alignment: .trailing)
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
    }

    private var comparisonValue: String {
        switch comparisonMode {
        case .yearDelta:
            let sign = row.yearOverYearChange >= 0 ? "+" : ""
            return sign + currency(row.yearOverYearChange)
        case .previousBalance:
            return currency(row.previousBalance)
        case .totalContributions:
            return currency(row.contributed)
        case .yearlyContributions:
            return currency(row.yearlyContributions)
        case .investmentGrowth:
            let sign = row.interestEarned >= 0 ? "+" : ""
            return sign + currency(row.interestEarned)
        }
    }

    private var comparisonColor: Color {
        let signedValue: Double
        switch comparisonMode {
        case .yearDelta:
            signedValue = row.yearOverYearChange
        case .investmentGrowth:
            signedValue = row.interestEarned
        case .previousBalance, .totalContributions, .yearlyContributions:
            return .secondary
        }

        if signedValue > 0 {
            return .teal
        } else if signedValue < 0 {
            return .red
        } else {
            return .secondary
        }
    }

    private func currency(_ value: Double) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
    }
}

#Preview {
    NavigationStack {
        InvestmentCalculatorView()
    }
}
