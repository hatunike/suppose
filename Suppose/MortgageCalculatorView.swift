import SwiftUI

struct MortgageCalculatorView: View {
    // Inputs are stored in UserDefaults so they survive navigation and app relaunches;
    // each field keeps whatever the user last entered.
    @AppStorage("mortgage.principalBalance") private var principalBalance = 320_000.0
    @AppStorage("mortgage.annualInterestRate") private var annualInterestRate = 6.5
    @AppStorage("mortgage.monthlyPrincipalInterest") private var monthlyPrincipalInterest = 2_100.0
    @AppStorage("mortgage.additionalMonthlyPayment") private var additionalMonthlyPayment = 200.0
    @FocusState private var focusedInput: MortgageInput?

    private var scenario: MortgageScenario {
        MortgageScenario(
            principalBalance: principalBalance,
            annualInterestRate: annualInterestRate,
            monthlyPrincipalInterest: monthlyPrincipalInterest,
            additionalMonthlyPayment: additionalMonthlyPayment
        )
    }

    private var comparison: MortgagePayoffComparison {
        MortgageAmortizationCalculator.comparison(for: scenario)
    }

    private var amortization: MortgageAmortization {
        comparison.accelerated
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: .now)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                inputs
                summary
                if !amortization.years.isEmpty {
                    breakdown
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mortgage")
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
            currencyField("Current Principal", value: $principalBalance, input: .principalBalance)
            percentField("Interest", value: $annualInterestRate)
            currencyField("Monthly (P&I)", value: $monthlyPrincipalInterest, input: .monthlyPrincipalInterest)
            currencyField("Additional Monthly", value: $additionalMonthlyPayment, input: .additionalMonthlyPayment)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var summary: some View {
        if amortization.isPaidOff {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    metric("Payoff time", text: payoffText(months: amortization.monthsToPayoff))
                    metric("Total interest", text: currency(amortization.totalInterest))
                }

                if additionalMonthlyPayment > 0 && comparison.baseline.isPaidOff {
                    metric("Interest saved", text: currency(comparison.interestSaved))
                    Text(savingsSentence)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    metric("Total paid", text: currency(amortization.totalPaid))
                    if additionalMonthlyPayment > 0 {
                        Text("Without the additional payment, this balance never pays off.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
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
        } else {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("These values never pay the balance down. Increase the monthly payment or the additional payment.")
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.orange.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Yearly")
                    .font(.headline)
                Spacer()
                Text("Principal · Interest")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            LazyVStack(spacing: 8) {
                ForEach(amortization.years) { year in
                    AmortizationRow(
                        year: year,
                        originalBalance: scenario.principalBalance,
                        startYear: currentYear
                    )
                }
            }
        }
    }

    private var savingsSentence: String {
        let extra = currency(additionalMonthlyPayment)
        let time = payoffText(months: comparison.monthsSaved)
        let interest = currency(comparison.interestSaved)
        let invested = currency(comparison.investedInstead(annualReturn: MortgageAmortizationCalculator.opportunityCostRealReturn))
        let originalTerm = payoffText(months: comparison.baseline.monthsToPayoff)
        return "Paying \(extra) extra each month clears the loan \(time) sooner and saves \(interest) in interest. Invested instead at a 7% real return over the loan's original \(originalTerm) term, that money would grow to \(invested)."
    }

    private func metric(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.title3.weight(.bold).monospacedDigit())
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func currencyField(_ title: String, value: Binding<Double>, input: MortgageInput) -> some View {
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
                TextField(title, value: value, format: .number.precision(.fractionLength(0...3)))
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
}

private func payoffText(months: Int) -> String {
    let years = months / 12
    let remainingMonths = months % 12
    switch (years, remainingMonths) {
    case (0, _):
        return "\(remainingMonths) mo"
    case (_, 0):
        return "\(years) yr"
    default:
        return "\(years) yr \(remainingMonths) mo"
    }
}

private func currency(_ value: Double) -> String {
    value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
}

private enum MortgageInput: Hashable {
    case principalBalance
    case annualInterestRate
    case monthlyPrincipalInterest
    case additionalMonthlyPayment
}

private struct AmortizationRow: View {
    let year: MortgageAmortizationYear
    let originalBalance: Double
    let startYear: Int

    private var paidOff: Double {
        max(0, originalBalance - year.endingBalance)
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Year \(year.year)")
                    .font(.subheadline.weight(.semibold))
                Text(verbatim: "\(startYear + year.year - 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 76, alignment: .leading)

            VStack(alignment: .leading, spacing: 5) {
                Text(currency(year.endingBalance))
                    .font(.headline.monospacedDigit())
                ProgressView(value: paidOff, total: max(originalBalance, 1))
                    .tint(.teal)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text(currency(year.principalReduction))
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.teal)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(currency(year.interestPaid))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 96, alignment: .trailing)
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        MortgageCalculatorView()
    }
}
