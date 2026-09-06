import SwiftUI

struct WithdrawalRateGridView: View {
    @State private var portfolio: PortfolioAllocation = .sixtyForty
    @State private var threshold: BalanceThreshold = .ranOut
    @State private var direction: ComparisonDirection = .atOrBelow

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            gridCard
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Withdrawal Rate")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            controlRow(title: "Portfolio mix") {
                Button {
                    portfolio.toggle()
                } label: {
                    Text(portfolio.title)
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            controlRow(title: "Tap shows chance balance ends") {
                HStack(spacing: 8) {
                    Button {
                        direction.toggle()
                    } label: {
                        Text(direction.symbol)
                            .font(.caption.weight(.bold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Menu {
                        ForEach(BalanceThreshold.allCases) { option in
                            Button(option.title) { threshold = option }
                        }
                    } label: {
                        Text(threshold.title)
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            Text("Each cell shows the annual withdrawal for that net worth and rate. Tap a cell to see the historical chance a 30-year retirement's ending balance is at or below (≤) or at or above (≥) the selected threshold; tap again to go back to the dollar amount.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func controlRow(title: String, @ViewBuilder control: () -> some View) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
            control()
        }
    }

    private var gridCard: some View {
        FrozenPaneGrid(
            netWorths: WithdrawalRateGrid.netWorths,
            rates: WithdrawalRateGrid.withdrawalRates,
            portfolio: portfolio,
            threshold: threshold,
            direction: direction
        )
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(maxHeight: .infinity)
    }
}

/// A grid with a pinned top header row and pinned first column, so both stay
/// visible while the body scrolls in either direction — like a spreadsheet's
/// frozen panes. The header/column each mirror the body's scroll offset along
/// the axis they don't freeze, via `onScrollGeometryChange`.
private struct FrozenPaneGrid: View {
    let netWorths: [Double]
    let rates: [Double]
    let portfolio: PortfolioAllocation
    let threshold: BalanceThreshold
    let direction: ComparisonDirection

    private let labelColumnWidth: CGFloat = 78
    private let cellWidth: CGFloat = 66
    private let headerHeight: CGFloat = 32
    private let rowHeight: CGFloat = 52

    @State private var contentOffset: CGPoint = .zero

    private var contentWidth: CGFloat { cellWidth * CGFloat(rates.count) }
    private var contentHeight: CGFloat { rowHeight * CGFloat(netWorths.count) }

    var body: some View {
        GeometryReader { proxy in
            let bodyWidth = max(0, proxy.size.width - labelColumnWidth)
            let bodyHeight = max(0, proxy.size.height - headerHeight)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    cornerCell
                    headerRow
                        .offset(x: -contentOffset.x)
                        .frame(width: contentWidth, height: headerHeight, alignment: .topLeading)
                        .frame(width: bodyWidth, height: headerHeight, alignment: .topLeading)
                        .clipped()
                }
                HStack(spacing: 0) {
                    leftColumn
                        .offset(y: -contentOffset.y)
                        .frame(width: labelColumnWidth, height: contentHeight, alignment: .topLeading)
                        .frame(width: labelColumnWidth, height: bodyHeight, alignment: .topLeading)
                        .clipped()
                    ScrollView([.horizontal, .vertical]) {
                        bodyGrid
                    }
                    .frame(width: bodyWidth, height: bodyHeight)
                    .onScrollGeometryChange(for: CGPoint.self) { geometry in
                        geometry.contentOffset
                    } action: { _, newValue in
                        contentOffset = newValue
                    }
                }
            }
        }
    }

    private var cornerCell: some View {
        Text("Net worth")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(width: labelColumnWidth, height: headerHeight, alignment: .leading)
            .background(.background)
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(rates, id: \.self) { rate in
                Text(ratePercentLabel(rate))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: cellWidth, height: headerHeight)
            }
        }
        .background(.background)
    }

    private var leftColumn: some View {
        VStack(spacing: 0) {
            ForEach(netWorths, id: \.self) { netWorth in
                Text(shortCurrency(netWorth))
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .frame(width: labelColumnWidth, height: rowHeight, alignment: .leading)
            }
        }
        .background(.background)
    }

    private var bodyGrid: some View {
        VStack(spacing: 0) {
            ForEach(netWorths, id: \.self) { netWorth in
                HStack(spacing: 0) {
                    ForEach(rates, id: \.self) { rate in
                        WithdrawalCell(netWorth: netWorth, ratePercent: rate, portfolio: portfolio, threshold: threshold, direction: direction)
                            .frame(width: cellWidth, height: rowHeight)
                    }
                }
            }
        }
    }
}

private struct WithdrawalCell: View {
    let netWorth: Double
    let ratePercent: Double
    let portfolio: PortfolioAllocation
    let threshold: BalanceThreshold
    let direction: ComparisonDirection
    @State private var isRevealed = false

    private var chancePercent: Int {
        portfolio.chanceEndingBalance(direction, threshold: threshold, forWithdrawalRate: ratePercent)
    }

    private var chanceColor: Color {
        switch chancePercent {
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
                    Text("\(chancePercent)%")
                        .foregroundStyle(chanceColor)
                } else {
                    Text(currency(WithdrawalRateGrid.annualWithdrawal(netWorth: netWorth, ratePercent: ratePercent)))
                        .foregroundStyle(.primary)
                }
            }
            .font(.caption.weight(.semibold).monospacedDigit())
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
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
