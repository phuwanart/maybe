# == Schema Information
#
# Table name: loans
#
#  id                :uuid             not null, primary key
#  initial_balance   :decimal(19, 4)
#  interest_rate     :decimal(10, 3)
#  locked_attributes :jsonb
#  rate_type         :string
#  term_months       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "calculates correct monthly payment for fixed rate loan" do
    loan_account = Account.create! \
      family: families(:dylan_family),
      name: "Mortgage Loan",
      balance: 500000,
      currency: "USD",
      accountable: Loan.create!(
        interest_rate: 3.5,
        term_months: 360,
        rate_type: "fixed"
      )

    assert_equal 2245, loan_account.loan.monthly_payment.amount
  end
end
