import SwiftUI

struct HistoricalReturnsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                columnLabels
                list
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Market History")
    }

    private var header: some View {
        Text("S&P 500 total return (with dividends), US CPI inflation, and the resulting real return for every year since 1928. Sourced from NYU Stern's historical returns dataset and BLS CPI figures — refresh yearly and verify against the primary sources if precision matters.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var columnLabels: some View {
        HStack(spacing: 0) {
            Text("Year")
                .frame(width: 52, alignment: .leading)
            Spacer()
            Text("Nominal")
                .frame(width: 74, alignment: .trailing)
            Text("Inflation")
                .frame(width: 74, alignment: .trailing)
            Text("Real")
                .frame(width: 74, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
    }

    private var list: some View {
        LazyVStack(spacing: 8) {
            ForEach(HistoricalMarketReturns.years.reversed()) { year in
                HistoricalYearRow(year: year)
            }
        }
    }
}

private struct HistoricalYearRow: View {
    let year: HistoricalMarketYear

    var body: some View {
        HStack(spacing: 0) {
            Text(String(year.year))
                .font(.subheadline.weight(.semibold))
                .frame(width: 52, alignment: .leading)
            Spacer()
            signedPercent(year.nominalReturnPercent)
                .frame(width: 74, alignment: .trailing)
            Text(signedPercentText(year.inflationRatePercent))
                .foregroundStyle(.secondary)
                .frame(width: 74, alignment: .trailing)
            signedPercent(year.realReturnPercent)
                .frame(width: 74, alignment: .trailing)
        }
        .font(.subheadline.monospacedDigit())
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func signedPercent(_ value: Double) -> some View {
        Text(signedPercentText(value))
            .foregroundStyle(value >= 0 ? .teal : .red)
    }

    private func signedPercentText(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return sign + value.formatted(.number.precision(.fractionLength(1))) + "%"
    }
}

#Preview {
    NavigationStack {
        HistoricalReturnsView()
    }
}
