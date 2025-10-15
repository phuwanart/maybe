# == Schema Information
#
# Table name: trades
#
#  id                :uuid             not null, primary key
#  currency          :string
#  locked_attributes :jsonb
#  price             :decimal(19, 4)
#  qty               :decimal(19, 4)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  security_id       :uuid             not null
#
# Indexes
#
#  index_trades_on_security_id  (security_id)
#
# Foreign Keys
#
#  fk_rails_...  (security_id => securities.id)
#
class Trade < ApplicationRecord
  include Entryable, Monetizable

  monetize :price

  belongs_to :security

  validates :qty, presence: true
  validates :price, :currency, presence: true

  class << self
    def build_name(type, qty, ticker)
      prefix = type == "buy" ? "Buy" : "Sell"
      "#{prefix} #{qty.to_d.abs} shares of #{ticker}"
    end
  end

  def unrealized_gain_loss
    return nil if qty.negative?
    current_price = security.current_price
    return nil if current_price.nil?

    current_value = current_price * qty.abs
    cost_basis = price_money * qty.abs

    Trend.new(current: current_value, previous: cost_basis)
  end
end
