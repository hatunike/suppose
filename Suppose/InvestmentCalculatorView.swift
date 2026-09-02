import SwiftUI

struct InvestmentCalculatorView: View {
    @State private var startingValue = 10000.0
    @State private var monthlyContribution = 500.0
    @State private var annualInterestRate = 7.0
    @State private var currentAge = 35
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
                header
                inputs
                summary
                projectionList
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Suppose Investment")
        .navigationBarTitleDisplayMode(.inline)
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suppose Investment")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
            Text("A 40-year offline projection with monthly contributions and monthly compounding.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var inputs: some View {
        VStack(spacing: 12) {
            currencyField("Starting value", value: $startingValue, input: .startingValue)
            currencyField("Monthly contribution", value: $monthlyContribution, input: .monthlyContribution)
            percentField("Annual interest rate", value: $annualInterestRate)
            ageStepper
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Projected outcome")
                .font(.headline)

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
                Text("Age \(currentAge + 1)-\(currentAge + scenario.projectionYears)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            LazyVStack(spacing: 8) {
                ForEach(projection) { row in
                    ProjectionRow(row: row, finalBalance: finalBalance)
                }
            }
        }
    }

    private var ageStepper: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Current age")
                    .font(.subheadline.weight(.semibold))
                Text("Used to label each projection year")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
            TextField(title, value: value, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .keyboardType(.decimalPad)
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

private struct ProjectionRow: View {
    let row: InvestmentProjectionYear
    let finalBalance: Double

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

            Text(row.contributed.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0))))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 82, alignment: .trailing)
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        InvestmentCalculatorView()
    }
}
