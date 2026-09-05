import SwiftUI

struct WithdrawalRateGridView: View {
    @State private var portfolio: PortfolioAllocation = .sixtyForty

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                grid
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Withdrawal Rate")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Historical basis")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    portfolio.toggle()
                } label: {
                    Text(portfolio.title)
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            Text("Each cell shows the annual withdrawal for that net worth and rate. Tap a cell to see the historical chance a 30-year retirement ran out of money at that rate; tap again to go back to the dollar amount.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var grid: some View {
        ScrollView(.horizontal) {
            Grid(horizontalSpacing: 6, verticalSpacing: 6) {
                GridRow {
                    Text("Net worth")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 72, alignment: .leading)
                    ForEach(WithdrawalRateGrid.withdrawalRates, id: \.self) { rate in
                        Text(ratePercentLabel(rate))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 64)
                    }
                }
                GridRow {
                    Divider().gridCellColumns(WithdrawalRateGrid.withdrawalRates.count + 1)
                }
                ForEach(WithdrawalRateGrid.netWorths, id: \.self) { netWorth in
                    GridRow {
                        Text(shortCurrency(netWorth))
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .frame(width: 72, alignment: .leading)
                        ForEach(WithdrawalRateGrid.withdrawalRates, id: \.self) { rate in
                            WithdrawalCell(netWorth: netWorth, ratePercent: rate, portfolio: portfolio)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct WithdrawalCell: View {
    let netWorth: Double
    let ratePercent: Double
    let portfolio: PortfolioAllocation
    @State private var isRevealed = false

    private var failureRate: Int {
        portfolio.failureRatePercent(forWithdrawalRate: ratePercent)
    }

    private var failureColor: Color {
        switch failureRate {
        case ..<5: .teal
        case 5..<15: .orange
        default: .red
        }
    }

    var body: some View {
        Button {
            isRevealed.toggle()
        } label: {
            Group {
                if isRevealed {
                    Text("\(failureRate)%")
                        .foregroundStyle(failureColor)
                } else {
                    Text(currency(WithdrawalRateGrid.annualWithdrawal(netWorth: netWorth, ratePercent: ratePercent)))
                        .foregroundStyle(.primary)
                }
            }
            .font(.caption.weight(.semibold).monospacedDigit())
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(width: 64)
        }
        .buttonStyle(.plain)
    }
}

private func ratePercentLabel(_ rate: Double) -> String {
    rate.formatted(.number.precision(.fractionLength(2))) + "%"
}

private func shortCurrency(_ value: Double) -> String {
    guard value >= 1_000_000 else {
        return "$\(Int(value / 1_000))k"
    }
    var text = String(format: "%.2f", value / 1_000_000)
    while text.hasSuffix("0") { text.removeLast() }
    if text.hasSuffix(".") { text.removeLast() }
    return "$\(text)M"
}

private func currency(_ value: Double) -> String {
    value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
}

#Preview {
    NavigationStack {
        WithdrawalRateGridView()
    }
}
