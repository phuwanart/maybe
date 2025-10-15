# == Schema Information
#
# Table name: credit_cards
#
#  id                :uuid             not null, primary key
#  annual_fee        :decimal(10, 2)
#  apr               :decimal(10, 2)
#  available_credit  :decimal(10, 2)
#  expiration_date   :date
#  locked_attributes :jsonb
#  minimum_payment   :decimal(10, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class CreditCard < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "credit_card" => { short: "Credit Card", long: "Credit Card" }
  }.freeze

  class << self
    def color
      "#F13636"
    end

    def icon
      "credit-card"
    end

    def classification
      "liability"
    end
  end

  def available_credit_money
    available_credit ? Money.new(available_credit, account.currency) : nil
  end

  def minimum_payment_money
    minimum_payment ? Money.new(minimum_payment, account.currency) : nil
  end

  def annual_fee_money
    annual_fee ? Money.new(annual_fee, account.currency) : nil
  end
end
