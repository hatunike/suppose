import Foundation

/// Inputs a borrower can read directly off a monthly mortgage statement.
///
/// Only the principal-and-interest portion of the payment is modeled; escrow
/// for taxes and insurance does not pay down the loan and is left out.
struct MortgageScenario: Equatable {
    /// Unpaid principal balance ("principal balance" on the statement).
    var principalBalance: Double
    /// Note interest rate, as an annual percentage.
    var annualInterestRate: Double
    /// Scheduled monthly principal-and-interest payment.
    var monthlyPrincipalInterest: Double
    /// Extra amount applied to principal every month, on top of the scheduled payment.
    var additionalMonthlyPayment: Double

    init(
        principalBalance: Double,
        annualInterestRate: Double,
        monthlyPrincipalInterest: Double,
        additionalMonthlyPayment: Double
    ) {
        self.principalBalance = max(0, principalBalance)
        self.annualInterestRate = max(0, annualInterestRate)
        self.monthlyPrincipalInterest = max(0, monthlyPrincipalInterest)
        self.additionalMonthlyPayment = max(0, additionalMonthlyPayment)
    }

    var monthlyInterestRate: Double {
        annualInterestRate / 100 / 12
    }
}
