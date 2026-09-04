import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                toolList
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Suppose")
        }
    }

    private var toolList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tools")
                .font(.headline)

            ForEach(FinancialTool.allCases) { tool in
                NavigationLink(value: tool) {
                    ToolCard(tool: tool)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationDestination(for: FinancialTool.self) { tool in
            switch tool {
            case .investment:
                InvestmentCalculatorView()
            case .mortgage:
                MortgageCalculatorView()
            case .contributionRoom:
                ContributionRoomCalculatorView()
            }
        }
    }
}

private struct ToolCard: View {
    let tool: FinancialTool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: tool.symbolName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.teal)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(tool.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(tool.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    ContentView()
}
